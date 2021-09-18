use super::PageRoot;

use anyhow::Result;

pub fn query_page(url: &str) -> Result<()> {
    // Cut off query string
    let url = match url.find('?') {
        Some(idx) => &url[..idx],
        None => url,
    };
    // Append `.json` to URL in order to get a data response
    let url = format!("{}.json", url.trim_end_matches("/"));

    let page_response: PageRoot = ureq::get(&url)
        .set("User-Agent", "reddit-ticker")
        .call()?
        .into_json()?;

    rid::log_debug!("Got page {:#?}", page_response);
    Ok(())
}