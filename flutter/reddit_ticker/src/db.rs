use std::time::{Duration, SystemTime, UNIX_EPOCH};

use anyhow::{anyhow, Result};
use rusqlite::{params, Connection};

use crate::reddit::Post;

pub const DB_NAME: &str = "reddit_ticker.sqlite";

pub struct DB {
    conn: Connection,
}

impl DB {
    // -----------------
    // Initializing Database
    // -----------------
    pub fn new(path: &str) -> Result<Self> {
        let conn = Connection::open(path)
            .map_err(|err| anyhow!("Failed to open Database at: {}\nError: {}", path, err))?;

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
CREATE INDEX IF NOT EXISTS idx_post_id ON reddit_scores (post_id);
COMMIT;
",
            )
            .map_err(|err| anyhow!("Failed to create Database tables:\nError: {}", err))
    }

    // -----------------
    // Inserting Posts and Scores
    // -----------------
    pub fn insert_post(&self, post: &Post) -> Result<usize> {
        let added: u32 = time_stamp_to_secs(post.added);

        self.conn
            .execute(
                "
INSERT OR IGNORE INTO reddit_posts (post_id, title, url, added)
VALUES (?1, ?2, ?3, ?4);
",
                params!(post.id, post.title, post.url, added),
            )
            .map_err(|err| anyhow!("Failed to add post with id {}:\nError: {}", post.id, err))
    }

    pub fn insert_score(&self, post_id: &str, time_stamp: SystemTime, score: i32) -> Result<usize> {
        let added = time_stamp_to_secs(time_stamp);
        let res = self
            .conn
            .execute(
                "
INSERT OR IGNORE INTO reddit_scores (post_id, added, score)
VALUES (?1, ?2, ?3);
",
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

// -----------------
// Timestamp Utils
// -----------------

// We keep timestamps stored as secs since  `UNIX_EPOCH` in order to be able to store them as u32
// which is the largest `INTEGER` supported by sqlite.

/// Takes a [UNIX_EPOCH] based [SystemTime] timestamp and converts it to seconds.
fn time_stamp_to_secs(time_stamp: SystemTime) -> u32 {
    // max u32:          4,294,967,295
    // UNIX_EPOCH secs: ~1,631,804,843
    time_stamp.duration_since(UNIX_EPOCH).unwrap().as_secs() as u32
}

/// Converts seconds passed since [UNIX_EPOCH] to a [SystemTime].
fn secs_to_time_stamp(secs: u32) -> SystemTime {
    UNIX_EPOCH + Duration::from_secs(secs as u64)
}
