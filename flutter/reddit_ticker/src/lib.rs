use core::time;
use std::{
    collections::HashMap,
    path::Path,
    sync::{RwLockReadGuard, RwLockWriteGuard},
    thread,
    time::SystemTime,
};

use anyhow::{anyhow, Result};
use db::{DB, DB_NAME};
use reddit::{query_page, Post};
use rid::RidStore;

use crate::reddit::{query_score, Score, RESOLUTION_MILLIS};

mod db;
mod reddit;

// -----------------
// Store
// -----------------
#[rid::store]
#[rid::structs(Post)]
#[derive(rid::Config)]
pub struct Store {
    posts: HashMap<String, Post>,

    #[rid(skip)]
    polling: bool,
    #[rid(skip)]
    db: Option<DB>,
}

impl RidStore<Msg> for Store {
    fn create() -> Self {
        Self {
            posts: HashMap::new(),
            polling: false,
            db: None,
        }
    }

    fn update(&mut self, req_id: u64, msg: Msg) {
        match msg {
            Msg::Initialize(app_dir) => {
                // Guard against more than one polling thread
                if !self.polling {
                    self.polling = true;
                    poll_posts();
                }

                if self.db.is_none() {
                    let db_path = Path::new(&app_dir)
                        .join(DB_NAME)
                        .to_string_lossy()
                        .to_string();

                    match DB::new(&db_path) {
                        Ok(db) => {
                            self.db = Some(db);
                            rid::log_info!("Initialized Database at '{}'", db_path);
                        }
                        Err(err) => {
                            rid::severe!(
                                format!("Failed to open Database at '{}'", db_path),
                                err.to_string()
                            );
                        }
                    }
                }

                if let Some(db) = &self.db {
                    self.posts = match db.get_all_posts() {
                        Ok(posts) => {
                            let mut map = HashMap::<String, Post>::new();
                            for post in posts {
                                map.insert(post.id.clone(), post);
                            }
                            map
                        }
                        Err(err) => {
                            rid::error!("Failed to retrieve existings posts", err);
                            HashMap::new()
                        }
                    };
                }

                rid::post(Reply::Initialized(req_id));
            }

            Msg::StartWatching(url) => start_watching(req_id, url),
            Msg::StopWatching(id) => {
                self.posts.remove(&id);
                if let Some(db) = &self.db {
                    match db.delete_post(&id) {
                        Ok(rows) => {
                            rid::log_debug!("Removed post and {} scores from Database", rows - 1);
                        }
                        Err(err) => {
                            rid::error!("Failed to delete post from Database", err);
                        }
                    };
                };
                rid::post(Reply::StoppedWatching(req_id, id));
            }
        }
    }
}

impl Store {
    fn read() -> RwLockReadGuard<'static, Store> {
        store::read()
    }
    fn write() -> RwLockWriteGuard<'static, Store> {
        store::write()
    }
}

// -----------------
// Message
// -----------------
#[rid::message(Reply)]
enum Msg {
    Initialize(String),

    StartWatching(String),
    StopWatching(String),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
enum Reply {
    Initialized(u64),

    StartedWatching(u64, String),
    StoppedWatching(u64, String),
    FailedRequest(u64, String),

    UpdatedScores,
}

// -----------------
// Start watching Post
// -----------------
fn start_watching(req_id: u64, url: String) {
    thread::spawn(move || match try_start_watching(url) {
        Ok(post) => {
            let id = post.id.clone();
            Store::write().posts.insert(id.clone(), post);
            rid::post(Reply::StartedWatching(req_id, id))
        }
        Err(err) => rid::post(Reply::FailedRequest(req_id, err.to_string())),
    });
}

fn try_start_watching(url: String) -> Result<Post> {
    let page = query_page(&url)
        .map_err(|err| anyhow!("Failed to get valid page data: {}\nError: {} ", url, err))?;

    rid::log_debug!("Got page for url '{}' with id '{}'.", url, page.id);

    let added = SystemTime::now();
    let post = Post {
        added,
        id: page.id,
        title: page.title,
        url: page.url,
        scores: vec![],
    };

    if let Some(db) = Store::read().db.as_ref() {
        if let Err(err) = db.insert_post(&post) {
            rid::error!("Failed to insert post", err.to_string());
        }
    }
    Ok(post)
}

// -----------------
// Polling Scores
// -----------------
fn poll_posts() {
    rid::log_debug!("Creating thread to poll post data");
    thread::spawn(move || loop {
        // First we query all posts and only take a write lock on the store once we have all the
        // data in order to limit the amount of time that the UI or other threads cannot access the
        // store.

        // In order to release the read lock on the store immediately, we clone the post ids.
        let post_ids: Vec<_> = { Store::read().posts.keys().cloned().collect() };
        let scores: Vec<_> = post_ids
            .into_iter()
            .map(|id| {
                let score = query_score(&id);
                (id, score)
            })
            // Filter out all cases where we couldn't update the score and send an error so that we
            // can log the problem and alert the user
            .filter_map(|(id, score_res)| match score_res {
                Ok(score) => Some((id, score)),
                Err(err) => {
                    rid::error!("Failed to update score for a post", err.to_string());
                    None
                }
            })
            .collect();

        {
            // Aquire a write lock on the store once and make sure it gets dropped (at the end of
            // this block) when we no longer need it
            let mut store = Store::write();
            for (id, score) in scores {
                // A post could have been removed in between getting the post ids and aquiring
                // the write lock.
                if !store.posts.contains_key(&id) {
                    continue;
                }

                let time_stamp = SystemTime::now();
                let post = &mut store.posts.get_mut(&id).unwrap();
                let secs_since_post_added = time_stamp
                    .duration_since(post.added)
                    .expect("Getting duration")
                    .as_secs();

                post.scores.push(Score {
                    secs_since_post_added,
                    score,
                });

                if let Some(db) = &store.db.as_ref() {
                    if let Err(err) = db.insert_score(&id, time_stamp, score) {
                        rid::error!("Failed to add score for post", err.to_string());
                    }
                }
            }
        }
        rid::post(Reply::UpdatedScores);
        thread::sleep(time::Duration::from_millis(RESOLUTION_MILLIS));
    });
}
