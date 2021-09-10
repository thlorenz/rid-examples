use super::{ApiRoot, Page, PageRoot};

use anyhow::Result;

pub fn query_page(url: &str) -> Result<Page> {
    // Cut off query string
    let url = match url.find('?') {
        Some(idx) => &url[..idx],
        None => url,
    };
    let url = format!("{}.json", url.trim_end_matches("/"));

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

const API_INFO_URL: &str = "https://api.reddit.com/api/info";

pub fn query_score(id: &str) -> Result<i32> {
    let url = format!("{}?id={}", API_INFO_URL, id);
    let api_response: ApiRoot = ureq::get(&url)
        .set("User-Agent", "reddit-score")
        .call()?
        .into_json()?;
    Ok(api_response.data.children[0].data.score)
}
