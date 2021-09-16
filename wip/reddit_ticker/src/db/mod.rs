use std::time::{Duration, SystemTime, UNIX_EPOCH};

use anyhow::{anyhow, bail, Result};
use rusqlite::{params, Connection};

use crate::{reddit::Score, Post};

/// The time we use as the baseline for timestamps stored in our Database.
/// It is expressed as seconds passed since the [UNIX_EPOCH].
const TIME_BASE_SECS: u64 = 1631576216;

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
        let added: u32 = time_stamp_to_normalized_secs(post.added);

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
        let added = time_stamp_to_normalized_secs(time_stamp);
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

    // -----------------
    // Retrieving Posts and Scores
    // -----------------
    pub fn get_post(&self, post_id: &str) -> Result<Option<Post>> {
        let mut stmt = self.conn.prepare(
            "
SELECT post_id, title, url, added 
FROM reddit_posts
WHERE post_id = (?1);
",
        )?;
        let mut results = stmt.query_map(params!(post_id), |row| {
            Ok(Post {
                id: row.get(0)?,
                title: row.get(1)?,
                url: row.get(2)?,
                added: normalized_secs_to_time_stamp(row.get(3)?),
                scores: vec![],
            })
        })?;
        match results.next() {
            Some(res) => match res {
                Ok(post) => Ok(Some(post)),
                Err(err) => bail!(err),
            },
            None => Ok(None),
        }
    }

    pub fn get_scores(&self, post: &Post) -> Result<Vec<Score>> {
        let mut stmt = self.conn.prepare(
            "
SELECT added, score
FROM reddit_scores
WHERE post_id = (?1)
",
        )?;

        let results: Vec<_> = stmt
            .query_map(params!(post.id), |row| {
                // Score timestamps are stored relative to our base time, however the rest
                // of the app treats score timestamps based on the time the post was added.
                let secs: u32 = row.get(0)?;
                let time_stamp = normalized_secs_to_time_stamp(secs);
                let secs_since_post_added = time_stamp
                    .duration_since(post.added)
                    .expect("Invalid timestamp")
                    .as_secs();

                let score: i32 = row.get(1)?;

                Ok(Score {
                    secs_since_post_added,
                    score,
                })
            })?
            .filter_map(|x| match x {
                Ok(score) => Some(score),
                Err(err) => {
                    rid::log_warn!("Found invalid score in Database {}", err.to_string());
                    None
                }
            })
            .collect();
        Ok(results)
    }
}

// -----------------
// Timestamp Utils
// -----------------
// We keep timestamps stored as secs passed since our `TIME_BASE_SECS` which is much closer than
// the `UNIX_EPOCH` in order to be able to store them as u32 which is the largest `INTEGER`
// supported by sqlite.

/// Takes a [UNIX_EPOCH] based timestamp and returns the seconds passed since our [TIME_BASE_SECS].
fn time_stamp_to_normalized_secs(time_stamp: SystemTime) -> u32 {
    (time_stamp.duration_since(UNIX_EPOCH).unwrap().as_secs() - TIME_BASE_SECS) as u32
}

/// Takes the seconds passes since our [TIME_BASE_SECS] and returns the [SystemTime] based on
/// [UNIX_EPOCH]
fn normalized_secs_to_time_stamp(secs: u32) -> SystemTime {
    UNIX_EPOCH + Duration::from_secs(TIME_BASE_SECS + secs as u64)
}
