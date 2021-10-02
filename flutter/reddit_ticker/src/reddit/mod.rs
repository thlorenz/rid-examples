#![allow(unused_variables, dead_code)]
mod reddit;
mod reddit_api_response;
mod reddit_page_response;
use std::time::SystemTime;

pub use reddit::*;
pub use reddit_api_response::*;
pub use reddit_page_response::*;

pub const RESOLUTION_MILLIS: u64 = 5_000;

// -----------------
// Reddit Page
// -----------------
#[derive(Debug, Clone)]
pub struct Page {
    pub id: String,
    pub title: String,
    pub url: String,
}

// -----------------
// Reddit Score
// -----------------
#[rid::model]
#[derive(Debug)]
pub struct Score {
    pub secs_since_post_added: u64,
    pub score: i32,
}

// -----------------
// Reddit Post
// -----------------
#[rid::model]
#[rid::structs(Score)]
#[derive(Debug, rid::Config)]
pub struct Post {
    #[rid(skip)]
    pub added: SystemTime,

    pub id: String,
    pub title: String,
    pub url: String,

    pub scores: Vec<Score>,
}
