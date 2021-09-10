#[cfg(not(feature = "mock_reddit"))]
mod reddit;

mod reddit_api_response;
mod reddit_page_response;

#[cfg(not(feature = "mock_reddit"))]
pub use reddit::*;

pub use reddit_api_response::*;
pub use reddit_page_response::*;

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
    pub post_added_secs_ago: u64,
    pub score: i32,
}

#[cfg(feature = "mock_reddit")]
mod reddit_mock;
#[cfg(feature = "mock_reddit")]
pub use reddit_mock::*;
