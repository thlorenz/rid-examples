use rid::RidStore;

#[rid::store]
#[derive(Debug)]
pub struct Store {
    count: u32,
}

impl RidStore<Msg> for Store {
    fn create() -> Self {
        Self { count: 0 }
    }

    fn update(&mut self, req_id: u64, msg: Msg) {
        match msg {
            Msg::Inc => {
                self.count += 1;
                rid::post(Reply::Increased(req_id));
            }
            Msg::Add(n) => {
                self.count += n;
                rid::post(Reply::Added(req_id, n.to_string()));
            }
        }
    }
}

#[rid::message(Reply)]
#[derive(Debug)]
pub enum Msg {
    Inc,
    Add(u32),
}

#[rid::reply]
pub enum Reply {
    Increased(u64),
    Added(u64, String),
}
