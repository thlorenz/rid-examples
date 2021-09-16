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
        Page {
            id: String::from("reddit_page_4"),
            title: String::from("How to make the borrow checkery your friend"),
            url: String::from("https://4"),
        },
        Page {
            id: String::from("reddit_page_5"),
            title: String::from("Does Rust have a Garbage Collector?"),
            url: String::from("https://5"),
        },
        Page {
            id: String::from("reddit_page_6"),
            title: String::from("Rust Podcasts"),
            url: String::from("https://6"),
        },
        Page {
            id: String::from("reddit_page_7"),
            title: String::from("Why is Rust better than C?"),
            url: String::from("https://7"),
        },
        Page {
            id: String::from("reddit_page_8"),
            title: String::from("Tutorial on running Flutter on Fuchsia"),
            url: String::from("https://8"),
        },
        Page {
            id: String::from("reddit_page_9"),
            title: String::from("Books to learn Flutter Development"),
            url: String::from("https://9"),
        },
        Page {
            id: String::from("reddit_page_10"),
            title: String::from("What are some advantages of Static Languages?"),
            url: String::from("https://10"),
        },
    ]
}

pub fn query_page(url: &str) -> Result<Page> {
    let idx = match url {
        "https://1" => 0,
        "https://2" => 1,
        "https://3" => 2,
        "https://4" => 3,
        "https://5" => 4,
        "https://6" => 5,
        "https://7" => 6,
        "https://8" => 7,
        "https://9" => 8,
        "https://10" => 9,
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
