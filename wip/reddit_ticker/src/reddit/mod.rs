mod reddit_api_response;
mod reddit_page_response;

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
    /// The amount of seconds passed since the post this score belongs to was added,
    /// i.e. the age of the score based on the age of the post.
    pub secs_since_post_added: u64,

    /// The score itself
    pub score: i32,
}

// -----------------
// Real Reddit Access
// -----------------
#[cfg(not(feature = "mock_reddit"))]
mod reddit;
#[cfg(not(feature = "mock_reddit"))]
pub use reddit::*;

// -----------------
// Mock Reddit Access
// -----------------
#[cfg(feature = "mock_reddit")]
mod reddit_mock;
#[cfg(feature = "mock_reddit")]
pub use reddit_mock::*;
