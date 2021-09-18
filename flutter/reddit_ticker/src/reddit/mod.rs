mod reddit;
mod reddit_api_response;
mod reddit_page_response;

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
