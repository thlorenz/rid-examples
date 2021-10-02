use std::time::{Duration, SystemTime, UNIX_EPOCH};

use anyhow::{anyhow, Result};
use rusqlite::{params, Connection, Row, NO_PARAMS};

use crate::reddit::{Post, Score};

pub const DB_NAME: &str = "reddit_ticker.sqlite";

pub struct DB {
    conn: Connection,
}

impl DB {
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
    // Insert Posts and Scores
    // -----------------

    pub fn insert_post(&self, post: &Post) -> Result<usize> {
        let added: u32 = time_stamp_to_secs(post.added);
        self.conn
            .execute(
                "
INSERT OR IGNORE INTO reddit_posts (post_id, title, url, added)
VALUES (?1, ?2, ?3, ?4);
                ",
                params![post.id, post.title, post.url, added],
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
    // -----------------
    // Retrieving Posts and Scores
    // -----------------
    pub fn get_scores(&self, post: &Post) -> Result<Vec<Score>> {
        let mut stmt = self.conn.prepare(
            "
SELECT added, score
FROM reddit_scores
WHERE post_id = (?1)
",
        )?;

        let results: Vec<_> = stmt
            .query_map(params!(post.id), |row| try_extract_score(row, post.added))?
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

    pub fn get_all_posts(&self) -> Result<Vec<Post>> {
        let mut stmt = self.conn.prepare(
            "
SELECT post_id, title, url, added 
FROM reddit_posts;
",
        )?;
        let results = stmt.query_map(NO_PARAMS, try_extract_post)?;
        let mut posts: Vec<_> = results
            .filter_map(|res| match res {
                Ok(post) => Some(post),
                Err(err) => {
                    rid::error!("A post couldn't be properly extracted", err.to_string());
                    None
                }
            })
            .collect();

        for mut post in posts.iter_mut() {
            let scores = self.get_scores(&post)?;
            post.scores = scores
        }
        Ok(posts)
    }

    // -----------------
    // Deleting Posts and Scores
    // -----------------
    pub fn delete_post(&self, post_id: &str) -> Result<usize> {
        let post_rows_removed = self
            .conn
            .execute(
                "
DELETE FROM reddit_posts 
WHERE post_id = (?1);
",
                params!(post_id),
            )
            .map_err(|err| anyhow!("Failed to remove post from table:\nError: {}", err))?;

        let score_rows_removed = self
            .conn
            .execute(
                "
DELETE FROM reddit_scores 
WHERE post_id = (?1);
",
                params!(post_id),
            )
            .map_err(|err| anyhow!("Failed to remove scores from table:\nError: {}", err))?;
        Ok(post_rows_removed + score_rows_removed)
    }
}

// -----------------
// Sqlite helpers
// -----------------
fn try_extract_score(row: &Row, post_added: SystemTime) -> rusqlite::Result<Score> {
    // Score timestamps are stored [UNIX_EPOCH] seconds, however the rest
    // of the app treats score timestamps based on the time the post was added.
    let secs: u32 = row.get(0)?;
    let time_stamp = secs_to_time_stamp(secs);
    let secs_since_post_added = time_stamp
        .duration_since(post_added)
        .expect("Invalid timestamp")
        .as_secs();

    let score: i32 = row.get(1)?;

    Ok(Score {
        secs_since_post_added,
        score,
    })
}

fn try_extract_post(row: &Row) -> rusqlite::Result<Post> {
    Ok(Post {
        id: row.get(0)?,
        title: row.get(1)?,
        url: row.get(2)?,
        added: secs_to_time_stamp(row.get(3)?),
        scores: vec![],
    })
}
fn time_stamp_to_secs(time_stamp: SystemTime) -> u32 {
    // max u32:          4,294,967,295
    // UNIX_EPOCH secs: ~1,631,804,843
    time_stamp.duration_since(UNIX_EPOCH).unwrap().as_secs() as u32
}

fn secs_to_time_stamp(secs: u32) -> SystemTime {
    UNIX_EPOCH + Duration::from_secs(secs as u64)
}
