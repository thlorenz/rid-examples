use std::time::{Duration, SystemTime, UNIX_EPOCH};

use anyhow::{anyhow, bail, Context, Result};
use rusqlite::{params, Connection, OpenFlags, OptionalExtension, NO_PARAMS};

use crate::{reddit::Score, Post};

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
CREATE INDEX IF NOT EXISTS idx_post_id ON reddit_scores (post_id);
COMMIT;
",
            )
            .map_err(|err| anyhow!("Failed to create DataBase tables:\nError: {}", err))
    }

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
                let secs: u32 = row.get(0)?;
                let time_stamp = normalized_secs_to_time_stamp(secs);
                let post_added_secs_ago = time_stamp
                    .duration_since(post.added)
                    .expect("Invalid timestamp")
                    .as_secs();

                let score: i32 = row.get(1)?;

                let score = Score {
                    post_added_secs_ago,
                    score,
                };
                Ok(score)
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

fn time_stamp_to_normalized_secs(time_stamp: SystemTime) -> u32 {
    (time_stamp.duration_since(UNIX_EPOCH).unwrap().as_secs() - TIME_BASE_SECS) as u32
}

fn normalized_secs_to_time_stamp(secs: u32) -> SystemTime {
    UNIX_EPOCH + Duration::from_secs(TIME_BASE_SECS + secs as u64)
}
