mod db;
mod reddit;

use core::time;
use std::{
    collections::HashMap,
    path::Path,
    sync::{RwLockReadGuard, RwLockWriteGuard},
    thread,
    time::SystemTime,
};

use db::{DB, DB_NAME};
use reddit::{query_page, query_score, Score};

use anyhow::{anyhow, Result};
use rid::RidStore;

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
        let posts = HashMap::new();
        Self {
            posts,
            polling: false,
            db: None,
        }
    }

    fn update(&mut self, req_id: u64, msg: Msg) {
        match msg {
            Msg::StartWatching(url) => start_watching(req_id, url),
            Msg::Initialize(app_dir) => {
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
                    };
                }
                if !self.polling {
                    self.polling = true;
                    poll_posts();
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
                            rid::error!("Failed to retrieve existing posts", err);
                            HashMap::new()
                        }
                    };
                    rid::log_info!(
                        "Loaded {} existing post(s) from the Database",
                        self.posts.len()
                    );
                }

                rid::post(Reply::Initialized(req_id));
            }
            Msg::StopWatching(id) => {
                self.posts.remove(&id);
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
pub enum Msg {
    Initialize(String),

    StartWatching(String),
    StopWatching(String),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    Initialized(u64),

    StartedWatching(u64, String),
    StoppedWatching(u64, String),

    FailedRequest(u64, String),
    UpdatedScores,

    Log(String),
}

// -----------------
// Reddit Post
// -----------------
#[rid::model]
#[rid::structs(Score)]
#[derive(Debug, rid::Config)]
pub struct Post {
    #[rid(skip)]
    added: SystemTime,

    id: String,
    title: String,
    url: String,
    scores: Vec<Score>,
}

// ------------------------------------------------------------------------------------------
// ---------------               Application Functionality                -------------------
// ------------------------------------------------------------------------------------------

// -----------------
// Start watching Post
// -----------------
fn start_watching(req_id: u64, url: String) {
    thread::spawn(move || {
        match try_start_watching(url) {
            Ok(post) => {
                let id = post.id.clone();
                let mut store = Store::write();
                store.posts.insert(id.clone(), post);
                rid::post(Reply::StartedWatching(req_id, id))
            }
            Err(err) => rid::post(Reply::FailedRequest(req_id, err.to_string())),
        };
    });
}

fn try_start_watching(url: String) -> Result<Post> {
    let page = query_page(&url)
        .map_err(|err| anyhow!("Failed to get valid page data: {}\nError: {}", url, err))?;

    rid::log_debug!("Got page for url '{}' with id '{}'.", url, page.id);

    // Try to retrieve post and its scores from Database
    let post = if let Some(db) = Store::read().db.as_ref() {
        db.get_post(&page.id)?.map(|mut post| {
            post.scores = match db.get_scores(&post) {
                Ok(scores) => scores,
                Err(err) => {
                    // If we the post existed but we couldn't get the scores we alert the Flutter end about that issue
                    rid::error!(
                        format!("Found post '{}', but was unable to load scores", post.id),
                        err
                    );
                    Vec::new()
                }
            };
            post
        })
    } else {
        None
    };

    match post {
        Some(post) => {
            rid::log_debug!("Retrieved post with id '{}' from the Database", post.id);
            Ok(post)
        }
        None => {
            rid::log_debug!(
                "Post with id {} was not found in Database, creating it",
                page.id
            );
            let added = SystemTime::now();
            let post = Post {
                added,
                id: page.id,
                title: page.title,
                url: page.url,
                scores: vec![],
            };
            // Store the new post in the Database
            if let Some(db) = Store::read().db.as_ref() {
                if let Err(err) = db.insert_post(&post) {
                    rid::error!("Failed to insert post", err.to_string());
                }
            }
            Ok(post)
        }
    }
}

// -----------------
// Refresh watched Posts
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
                let score = query_score(&id.as_str());
                (id, score)
            })
            // Ignore all cases where we couldn't update the score
            // In the future we may emit a failure event here to show this problem in the Dart UI
            .filter_map(|(id, score_res)| match score_res {
                Ok(score) => Some((id, score)),
                Err(err) => {
                    rid::error!("Failed to update score for a post", err.to_string());
                    None
                }
            })
            .collect();

        {
            // Aquire a write lock to the store once and make sure it gets dropped (at the end of
            // this block) when we no longer need it
            let mut store = Store::write();
            for (id, score) in scores {
                let time_stamp = SystemTime::now();
                {
                    let post = &mut store.posts.get_mut(&id).unwrap();
                    let secs_since_post_added = time_stamp
                        .duration_since(post.added)
                        .expect("Getting duration")
                        .as_secs();

                    post.scores.push(Score {
                        secs_since_post_added,
                        score,
                    });
                }

                if let Some(db) = &mut store.db.as_mut() {
                    if let Err(err) = db.insert_score(&id, time_stamp, score) {
                        rid::error!("Failed to add score for post", err.to_string());
                    }
                }
            }
        }
        rid::post(Reply::UpdatedScores);
        thread::sleep(time::Duration::from_secs(1));
    });
}
