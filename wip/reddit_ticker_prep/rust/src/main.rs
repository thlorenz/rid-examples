use core::time;
use lazy_static::lazy_static;
use std::{
    collections::HashMap,
    sync::RwLock,
    thread::{self, JoinHandle},
};

use serde_page_partial::PageRoot;

use crate::serde_api_partial::ApiRoot;

mod serde_api_partial;
mod serde_page_partial;

const API_INFO_URL: &str = "https://api.reddit.com/api/info";

#[derive(Debug)]
struct Page {
    id: String,
    title: String,
    url: String,
}

fn query_page(url: &str) -> Result<Page, ureq::Error> {
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

#[derive(Debug)]
struct Post {
    id: String,
    title: String,
    url: String,
    scores: Vec<i64>,
}

type Posts = HashMap<String, Post>;

fn query_score(id: &str) -> Result<i64, ureq::Error> {
    let url = format!("{}?id={}", API_INFO_URL, id);
    let api_response: ApiRoot = ureq::get(&url)
        .set("User-Agent", "reddit-score")
        .call()?
        .into_json()?;
    Ok(api_response.data.children[0].data.score)
}

fn watch_posts(posts: &'static RwLock<Posts>) -> Vec<JoinHandle<()>> {
    eprintln!("Watching {:#?}", posts);

    let ids: Vec<_> = posts.read().unwrap().keys().cloned().collect();
    let mut threads: Vec<JoinHandle<_>> = vec![];
    for id in ids {
        let handle = thread::spawn(move || loop {
            thread::sleep(time::Duration::from_millis(2000));
            let score = query_score(&id).expect("Failed to get score");
            posts
                .write()
                .unwrap()
                .get_mut(&id)
                .unwrap()
                .scores
                .push(score);

            eprintln!("id: {}, {:#?}", id, posts.read().unwrap().get(&id));
        });
        threads.push(handle);
    }
    threads
}

lazy_static! {
    static ref POSTS: RwLock<Posts> = RwLock::new(Posts::new());
}

fn main() -> Result<(), ureq::Error> {
    let pages_to_track: Vec<&str> = vec![
        "https://www.reddit.com/r/rust/comments/ph6vso/lemmy_release_v0120_user_and_community_blocking/",
        "https://www.reddit.com/r/rust/comments/pglz9h/password_auth_in_rust_from_scratch_attacks_and/",
        "https://www.reddit.com/r/FlutterDev/comments/ph8a91/im_excited_to_announce_our_new_flutter_plugin_for/",
    ];
    let (pages, errors): (Vec<_>, Vec<_>) = pages_to_track
        .into_iter()
        .map(|url| query_page(&format!("{}.json", url.trim_end_matches("/"))))
        .partition(Result::is_ok);

    let pages: Vec<_> = pages.into_iter().map(Result::unwrap).collect();
    let errors: Vec<_> = errors.into_iter().map(Result::unwrap_err).collect();

    if !errors.is_empty() {
        eprintln!("Encountered errors {:#?}\n, exiting", errors);
        Ok(())
    } else {
        print!("ids: {:#?}", errors);
        for page in pages {
            POSTS.write().unwrap().insert(
                page.id.clone(),
                Post {
                    id: page.id,
                    title: page.title,
                    url: page.url,
                    scores: vec![],
                },
            );
        }

        let threads = watch_posts(&POSTS);
        for thread in threads {
            thread.join().expect("Thread failed to join");
        }
        Ok(())
    }
}
