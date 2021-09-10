use anyhow::{anyhow, Result};
use rusqlite::{params, Connection, OpenFlags, NO_PARAMS};

pub struct DB {
    conn: Connection,
}

impl DB {
    pub fn new(path: &str) -> Result<Self> {
        let flags = OpenFlags::SQLITE_OPEN_READ_WRITE | OpenFlags::SQLITE_OPEN_CREATE;
        let conn = Connection::open_with_flags(path, flags)
            .map_err(|err| anyhow!("Failed to open DataBase at: {}\nError: {}", path, err))?;

        let db = Self { conn };
        db.init_table()?;

        Ok(db)
    }

    fn init_table(&self) -> Result<usize> {
        self.conn
            .execute(
                "
CREATE TABLE IF NOT EXISTS reddit_posts (
    post_id  TEXT PRIMARY KEY,
    title    TEXT,
    url      TEXT,
    added    INTEGER
);
CREATE TABLE IF NOT EXISTS reddit_scores (
    post_id   TEXT PRIMARY KEY,
    added     INTEGER,
    score     INTEGER
);",
                NO_PARAMS,
            )
            .map_err(|err| anyhow!("Failed to create DataBase tables:\nError: {}", err))
    }

    pub fn insert_score(&self, post_id: &str, _score: i32) -> Result<usize> {
        let res = self
            .conn
            .execute(
                "INSERT OR IGNORE INTO reddit_scores (post_id, scores) VALUES (?1, ?2);",
                params!(post_id, ""),
            )
            .map_err(|err| anyhow!("Failed to insert post with id {}:\nError: {}", post_id, err))?;

        Ok(res)
    }
}
