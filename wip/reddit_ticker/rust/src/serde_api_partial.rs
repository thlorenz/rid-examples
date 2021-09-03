// Mostly generated via: https://transform.tools/json-to-rust-serde
use serde::{Deserialize, Serialize};

// ../reference/serde_api_full.rs with all fields removed that we don't need
#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ApiRoot {
    pub data: Data,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Data {
    pub children: Vec<Children>,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Children {
    pub data: Data2,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Data2 {
    pub score: i64,
}
