use anyhow::{anyhow, Result};

use crate::reddit::ApiRoot;

use super::{Page, PageRoot};

pub fn query_page(url: &str) -> Result<Page> {
    // Cut off query string
    let url = match url.find("?") {
        Some(idx) => &url[..idx],
        None => url,
    };

    let url = format!("{}.json", url.trim_end_matches("/"));

    let page_response: PageRoot = ureq::get(&url)
        .set("User-Agent", "reddit-ticker")
        .call()?
        .into_json()?;

    // .data.children[0].data.{title, id}
    let data = &page_response
        .first()
        .ok_or_else(|| anyhow!("Page response did not contain any pages"))?
        .data
        .children
        .first()
        .ok_or_else(|| anyhow!("The page did not contain any childre"))?
        .data;

    let id = data.name.clone();

    let title = data
        .title
        .as_ref()
        .ok_or_else(|| anyhow!("Page was missing a title"))?
        .clone();

    let url = data
        .url
        .as_ref()
        .ok_or_else(|| anyhow!("Page was missing a url"))?
        .clone();

    Ok(Page { id, title, url })
}

const API_INFO_URL: &str = "https://api.reddit.com/api/info";

pub fn query_score(id: &str) -> Result<i32> {
    let url = format!("{}?id={}", API_INFO_URL, id);

    let api_response: ApiRoot = ureq::get(&url)
        .set("User-Agent", "reddit-ticker")
        .call()?
        .into_json()?;

    let score = api_response
        .data
        .children
        .first()
        .ok_or_else(|| anyhow!("Post info was missing children"))?
        .data
        .score;

    Ok(score)
}
