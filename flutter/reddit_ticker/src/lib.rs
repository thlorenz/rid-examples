mod reddit;
use reddit::{query_page, query_score};

#[rid::export]
pub fn page_request() -> String {
    let page = query_page("https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/").expect("Should be able to get page");
    rid::log_info!("{:#?}", page);
    page.id
}

#[rid::export]
pub fn post_score_request(id: String) -> i32 {
    let score = query_score(&id).expect("Should have gotten score");
    score
}
