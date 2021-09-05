mod reddit_api_response;
mod reddit_page_response;

use core::time;
use std::{
    collections::HashMap,
    sync::{RwLockReadGuard, RwLockWriteGuard},
    thread,
};

use reddit_page_response::PageRoot;
use rid::RidStore;

use crate::reddit_api_response::ApiRoot;
use anyhow::{anyhow, Result};
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
        let posts = HashMap::new();
        Self { posts }
    }

    fn update(&mut self, req_id: u64, msg: Msg) {
        match msg {
            Msg::StartWatching(url) => start_watching(req_id, url),
            Msg::InitializeTicker => {
                poll_posts();
                rid::post(Reply::InitializedTicker(req_id));
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
// Start watching Post
// -----------------
fn start_watching(req_id: u64, url: String) {
    thread::spawn(move || {
        match try_start_watching(url) {
            Ok(post) => {
                let id = post.id.clone();
                Store::write().posts.insert(id.clone(), post);
                rid::post(Reply::StartedWatching(req_id, id))
            }
            Err(err) => rid::post(Reply::FailedRequest(req_id, err.to_string())),
        };
    });
}

fn try_start_watching(url: String) -> Result<Post> {
    let page =
        query_page(&url).map_err(|err| anyhow!("Failed to get page: {}\nError: {}", url, err))?;
    let post = Post {
        id: page.id,
        title: page.title,
        url: page.url,
        scores: vec![],
    };
    Ok(post)
}

// -----------------
// Refresh watched Posts
// -----------------
fn poll_posts() {
    thread::spawn(move || loop {
        // First we query all posts before and only take a write lock on the store
        // once we have all the data in order to limit the amount of time that the UI or other
        // threads cannot access the store.
        // In order to release the read lock on the store as soon as possible we clone the post
        // ids.
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
                Err(_) => None,
            })
            .collect();

        for (id, score) in scores {
            let mut store = Store::write();
            let post = store.posts.get_mut(&id).unwrap();
            post.scores.push(score);
        }
        rid::post(Reply::UpdatedScores);

        thread::sleep(time::Duration::from_secs(10));
    });
}

// -----------------
// Message
// -----------------
#[rid::message(Reply)]
pub enum Msg {
    InitializeTicker,

    StartWatching(String),
    StopWatching(String),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    InitializedTicker(u64),

    StartedWatching(u64, String),
    StoppedWatching(u64, String),

    FailedRequest(u64, String),
    UpdatedScores,
}

// -----------------
// Reddit Post
// -----------------
#[rid::model]
#[derive(Debug)]
pub struct Post {
    id: String,
    title: String,
    url: String,
    scores: Vec<i64>,
}

const API_INFO_URL: &str = "https://api.reddit.com/api/info";

fn query_score(id: &str) -> Result<i64, ureq::Error> {
    let url = format!("{}?id={}", API_INFO_URL, id);
    let api_response: ApiRoot = ureq::get(&url)
        .set("User-Agent", "reddit-score")
        .call()?
        .into_json()?;
    Ok(api_response.data.children[0].data.score)
}

// -----------------
// Reddit Page
// -----------------
#[derive(Debug)]
struct Page {
    id: String,
    title: String,
    url: String,
}

fn query_page(url: &str) -> Result<Page> {
    let url = format!("{}.json", url.trim_end_matches("/"));

    let page_response: PageRoot = ureq::get(&url)
        .set("User-Agent", "reddit-score")
        .call()?
        .into_json()?;

    let data = &page_response
        .first()
        .expect("Expected at least on page in the page result")
        .data
        .children
        .first()
        .expect("Expected at least one child in the page")
        .data;

    let id = data.name.clone();
    let title = data
        .title
        .as_ref()
        .expect("Expected page to have a title")
        .clone();

    let url = data
        .url
        .as_ref()
        .expect("Expected page to have a title")
        .clone();

    Ok(Page { id, title, url })
}
