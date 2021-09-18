use anyhow::{anyhow, Result};
use std::{
    collections::HashMap,
    sync::{RwLockReadGuard, RwLockWriteGuard},
    thread,
    time::SystemTime,
};

use reddit::Post;
use rid::RidStore;

use reddit::query_page;

mod reddit;

// -----------------
// Store
// -----------------
#[rid::store]
#[rid::structs(Post)]
pub struct Store {
    posts: HashMap<String, Post>,
}

impl RidStore<Msg> for Store {
    fn create() -> Self {
        Self {
            posts: HashMap::new(),
        }
    }

    fn update(&mut self, req_id: u64, msg: Msg) {
        match msg {
            Msg::StartWatching(url) => start_watching(req_id, url),
            Msg::StopWatching(id) => {
                self.posts.remove(&id);
                rid::post(Reply::StoppedWatching(req_id, id));
            }
        }
    }
}

// Helpers to improve code assist
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
    StartWatching(String),
    StopWatching(String),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    StartedWatching(u64, String),
    StoppedWatching(u64, String),

    FailedRequest(u64, String),
}

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

    let added = SystemTime::now();
    let post = Post {
        added,
        id: page.id,
        title: page.title,
        url: page.url,
        scores: vec![],
    };
    Ok(post)
}
