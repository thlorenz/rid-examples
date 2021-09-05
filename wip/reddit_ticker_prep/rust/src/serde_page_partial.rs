use serde::{Deserialize, Serialize};

// ../reference/serde_page_full.rs with all fields removed that we don't need
pub type PageRoot = Vec<Page>;

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Page {
    pub data: ChildContainer,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChildContainer {
    pub children: Vec<Children>,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Children {
    pub data: ChildData,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChildData {
    pub name: String,
    pub title: Option<String>,
    pub url: Option<String>,
}
