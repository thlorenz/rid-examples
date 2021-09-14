use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::{anyhow, Result};
use rusqlite::{params, Connection, OpenFlags};

use crate::Post;

const TIME_BASE_SECS: u64 = 1631576216;

pub struct DB {
    conn: Connection,
}

impl DB {
    pub fn new(path: &str) -> Result<Self> {
        let flags = OpenFlags::SQLITE_OPEN_READ_WRITE | OpenFlags::SQLITE_OPEN_CREATE;
        let conn = Connection::open_with_flags(path, flags)
            .map_err(|err| anyhow!("Failed to open DataBase at: {}\nError: {}", path, err))?;

        let db = Self { conn };
        db.init_tables()?;

        Ok(db)
    }

    fn init_tables(&self) -> Result<()> {
        self.conn
            .execute_batch(
                "
BEGIN;
CREATE TABLE IF NOT EXISTS reddit_posts (
    post_id  TEXT PRIMARY KEY,
    title    TEXT,
    url      TEXT,
    added    INTEGER
);
CREATE TABLE IF NOT EXISTS reddit_scores (
    post_id   TEXT,
    added     INTEGER,
    score     INTEGER
);
CREATE INDEX idx_post_id ON reddit_scores (post_id);
COMMIT;
",
            )
            .map_err(|err| anyhow!("Failed to create DataBase tables:\nError: {}", err))
    }

    pub fn insert_post(&self, post: &Post) -> Result<usize> {
        let added: u32 = time_stamp_to_normalized_secs(post.added);

        self.conn.execute(
            "INSERT OR IGNORE INTO reddit_posts (post_id, title, url, added) VALUES (?1, ?2, ?3, ?4);",
            params!(post.id, post.title, post.url, added))
            .map_err(|err| anyhow!("Failed to add post with id {}:\nError: {}", post.id, err))
    }

    pub fn insert_score(&self, post_id: &str, time_stamp: SystemTime, score: i32) -> Result<usize> {
        let added = time_stamp_to_normalized_secs(time_stamp);
        let res = self
            .conn
            .execute(
                "INSERT OR IGNORE INTO reddit_scores (post_id, added, score) VALUES (?1, ?2, ?3);",
                params!(post_id, added, score),
            )
            .map_err(|err| {
                anyhow!(
                    "Failed to insert score for post {}:\nError: {}",
                    post_id,
                    err
                )
            })?;

        Ok(res)
    }
}

fn time_stamp_to_normalized_secs(time_stamp: SystemTime) -> u32 {
    (time_stamp.duration_since(UNIX_EPOCH).unwrap().as_secs() - TIME_BASE_SECS) as u32
}
