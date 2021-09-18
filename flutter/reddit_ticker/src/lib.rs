mod reddit;

use reddit::query_page;

#[rid::export]
pub fn page_request() {
    let page = query_page("https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/")
        .expect("Should have succeeded");
    rid::log_info!("{:#?}", page);
}
