use crate::Store;

use super::Page;
use rand::{thread_rng, Rng};

use anyhow::{bail, Result};

fn mock_pages() -> Vec<Page> {
    vec![
        Page {
            id: String::from("reddit_page_1"),
            title: String::from("Why Rust and Flutter are made for each other"),
            url: String::from("https://1"),
        },
        Page {
            id: String::from("reddit_page_2"),
            title: String::from("Should I give rid a try?"),
            url: String::from("https://2"),
        },
        Page {
            id: String::from("reddit_page_3"),
            title: String::from("Starting into Rust for Flutter devs"),
            url: String::from("https://3"),
        },
    ]
}

pub fn query_page(url: &str) -> Result<Page> {
    let idx = match url {
        "https://1" => 0,
        "https://2" => 1,
        "https://3" => 2,
        url => bail!("Page {} not found", url),
    };

    Ok(mock_pages()[idx].clone())
}

pub fn query_score(id: &str) -> Result<i32> {
    let mut rng = thread_rng();
    let posts = &Store::read().posts;
    let score = match posts.get(id) {
        Some(post) => match post.scores.last() {
            Some(score) => {
                let delta = rng.gen_range(-3..6);
                score.score + delta
            }
            None => rng.gen_range(0..89),
        },
        None => bail!("Post with id {} not found", id),
    };
    Ok(score)
}
