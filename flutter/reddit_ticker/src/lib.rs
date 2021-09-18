use std::{collections::HashMap, time::SystemTime};

use reddit::Post;
use rid::RidStore;

mod reddit;

// -----------------
// Store
// -----------------
#[rid::store]
#[rid::structs(Post)]
pub struct Store {
    posts: HashMap<String, Post>,
}

impl RidStore<Msg> for Store {
    fn create() -> Self {
        let post_id = String::from("fake post 1");
        let post = Post {
            added: SystemTime::now(),
            id: post_id.clone(),
            title: String::from("My first fake reddit post"),
            url: String::from("https://fake.reddit.com/post1"),
            scores: vec![],
        };
        let posts = {
            let mut map = HashMap::new();
            map.insert(post_id, post);
            map
        };
        Self { posts }
    }

    fn update(&mut self, _req_id: u64, _msg: Msg) {
        todo!()
    }
}

enum Msg {}
