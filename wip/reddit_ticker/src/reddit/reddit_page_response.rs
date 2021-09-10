use serde::{Deserialize, Serialize};

pub type PageRoot = Vec<RedditPage>;

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RedditPage {
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
