mod reddit;
use reddit::query_page;

#[rid::export]
pub fn page_request() {
    query_page("https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/").expect("Should be able to get page");
}
