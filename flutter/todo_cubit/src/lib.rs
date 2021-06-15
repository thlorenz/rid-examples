use core::time;
use std::{
    sync::{RwLockReadGuard, RwLockWriteGuard},
    thread,
};

use rid::RidStore;

const COMPLETED_EXPIRY_MILLIS: u64 = 7000;
const EXPIRY_STEP: u64 = 10;

// -----------------
// Store
// -----------------
#[rid::store]
#[rid::structs(Todo, Settings)]
#[rid::enums(Filter)]
#[derive(Debug)]
pub struct Store {
    last_added_id: u32,
    todos: Vec<Todo>,
    filter: Filter,
    settings: Settings,
}

impl RidStore<Msg> for Store {
    fn create() -> Self {
        let first_todo = Todo {
            id: 0,
            title: "Learn Flutter".to_string(),
            completed: true,
            expiry_millis: COMPLETED_EXPIRY_MILLIS,
        };
        let second_todo = Todo {
            id: 1,
            title: "Learn Rust".to_string(),
            completed: true,
            expiry_millis: COMPLETED_EXPIRY_MILLIS,
        };
        let third_todo = Todo {
            id: 2,
            title: "Learn Rid".to_string(),
            completed: false,
            expiry_millis: COMPLETED_EXPIRY_MILLIS,
        };
        let fourth_todo = Todo {
            id: 3,
            title: "Build Awesome Apps".to_string(),
            completed: false,
            expiry_millis: COMPLETED_EXPIRY_MILLIS,
        };
        Self {
            last_added_id: 3,
            todos: vec![first_todo, second_todo, third_todo, fourth_todo],
            filter: Filter::All,
            settings: Settings {
                auto_expire_completed_todos: false,
                completed_expiry_millis: COMPLETED_EXPIRY_MILLIS,
            },
        }
    }

    fn update(&mut self, req_id: u64, msg: Msg) {
        use Msg::*;
        match msg {
            AddTodo(title) => {
                self.last_added_id += 1;
                let todo = Todo {
                    id: self.last_added_id,
                    title,
                    completed: false,
                    expiry_millis: COMPLETED_EXPIRY_MILLIS,
                };
                self.todos.push(todo);
                rid::post(Reply::AddedTodo(req_id, self.last_added_id.to_string()));
            }
            RemoveTodo(id) => {
                self.remove_todo(id);
                rid::post(Reply::RemovedTodo(req_id, self.last_added_id.to_string()));
            }

            RemoveCompleted => {
                self.todos.retain(|todo| !todo.completed);
                rid::post(Reply::RemovedCompleted(req_id));
            }

            CompleteTodo(id) => {
                self.update_todo(id, |todo| todo.set_completed(true));
                rid::post(Reply::CompletedTodo(req_id, id.to_string()));
            }
            RestartTodo(id) => {
                self.update_todo(id, |todo| todo.set_completed(false));
                rid::post(Reply::RestartedTodo(req_id, id.to_string()));
            }
            ToggleTodo(id) => {
                self.update_todo(id, |todo| todo.set_completed(!todo.completed));
                rid::post(Reply::ToggledTodo(req_id, id.to_string()));
            }

            CompleteAll => {
                self.todos.iter_mut().for_each(|x| x.set_completed(true));
                rid::post(Reply::CompletedAll(req_id));
            }
            RestartAll => {
                self.todos.iter_mut().for_each(|x| x.set_completed(false));
                rid::post(Reply::RestartedAll(req_id));
            }

            SetFilter(filter) => {
                self.filter = filter;
                rid::post(Reply::SetFilter(req_id));
            }
            SetAutoExpireCompletedTodos(expire) => {
                self.set_auto_expire_completed_todos(expire);
                rid::post(Reply::SetAutoExpireCompletedTodos(req_id));
            }
        };
    }
}

#[rid::export]
#[rid::structs(Todo)]
impl Store {
    fn remove_todo(&mut self, id: u32) {
        let mut enumerated = self.todos.iter().enumerate();
        let idx = match enumerated.find(|(_, todo)| todo.id == id) {
            Some((idx, _)) => idx,
            None => return eprintln!("Could not find Todo with id '{}'", id),
        };
        self.todos.remove(idx);
    }

    fn update_todo<F: FnOnce(&mut Todo)>(&mut self, id: u32, update: F) {
        match self.todos.iter_mut().find(|x| x.id == id) {
            Some(todo) => update(todo),
            None => eprintln!("Could not find Todo with id '{}'", id),
        };
    }

    #[rid::export]
    fn filtered_todos(&self) -> Vec<&Todo> {
        let mut vec: Vec<&Todo> = match self.filter {
            Filter::Completed => self.todos.iter().filter(|x| x.completed).collect(),
            Filter::Pending => self.todos.iter().filter(|x| !x.completed).collect(),
            Filter::All => self.todos.iter().collect(),
        };
        vec.sort();
        vec
    }

    #[rid::export]
    fn todo_by_id(&self, id: u32) -> Option<&Todo> {
        self.todos.iter().find(|x| x.id == id)
    }

    // The below read/write wrappers help with auto complete since procmacros
    // aren't very well supported by the rust analyzer yet
    fn read() -> RwLockReadGuard<'static, Store> {
        store::read()
    }

    fn write() -> RwLockWriteGuard<'static, Store> {
        store::write()
    }

    pub fn set_auto_expire_completed_todos(&mut self, expire: bool) {
        self.settings.auto_expire_completed_todos = expire;
        if expire {
            thread::spawn(move || {
                eprintln!(
                    "rust: thread {:?} started auto expiring",
                    thread::current().id()
                );
                while Store::read().settings.auto_expire_completed_todos {
                    thread::sleep(time::Duration::from_millis(EXPIRY_STEP));
                    {
                        let ids_to_update: Vec<(u32, bool)> = Store::write()
                            .todos
                            .iter_mut()
                            .filter(|x| x.completed)
                            .map(|x: &mut Todo| {
                                let next_value = x.expiry_millis - EXPIRY_STEP;
                                if next_value <= 0 {
                                    (x.id, true)
                                } else {
                                    x.expiry_millis = next_value;
                                    (x.id, false)
                                }
                            })
                            .collect();

                        for (id, remove) in ids_to_update {
                            if remove {
                                Store::write().remove_todo(id);
                                rid::post(Reply::CompletedTodoExpired);
                            } else {
                                rid::post(Reply::Tick(id.to_string()));
                            }
                        }
                    }
                }
                eprintln!(
                    "rust: thread {:?} stopped auto expiring",
                    thread::current().id()
                );
            });
        }
    }
}

// -----------------
// Settings
// -----------------
#[rid::model]
#[derive(Debug)]
pub struct Settings {
    auto_expire_completed_todos: bool,
    completed_expiry_millis: u64,
}

// -----------------
// Todo Model
// -----------------
#[rid::model]
#[derive(PartialEq, Eq, PartialOrd, Debug)]
pub struct Todo {
    id: u32,
    title: String,
    completed: bool,
    expiry_millis: u64,
}

impl Todo {
    fn set_completed(&mut self, completed: bool) {
        self.completed = completed;
        self.expiry_millis = COMPLETED_EXPIRY_MILLIS;
    }
}

impl Ord for Todo {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.id.cmp(&other.id)
    }
}

// -----------------
// Filter
// -----------------
#[rid::model]
#[derive(Clone, Debug)]
pub enum Filter {
    Completed,
    Pending,
    All,
}

// -----------------
// Msg
// -----------------
#[rid::message(Reply)]
#[rid::enums(Filter)]
#[derive(Debug)]
pub enum Msg {
    AddTodo(String),
    RemoveTodo(u32),
    RemoveCompleted,

    CompleteTodo(u32),
    RestartTodo(u32),
    ToggleTodo(u32),
    CompleteAll,
    RestartAll,

    SetFilter(Filter),
    SetAutoExpireCompletedTodos(bool),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    // Message Replies
    AddedTodo(u64, String),
    RemovedTodo(u64, String),
    RemovedCompleted(u64),

    CompletedTodo(u64, String),
    RestartedTodo(u64, String),
    ToggledTodo(u64, String),
    CompletedAll(u64),
    RestartedAll(u64),

    SetFilter(u64),
    SetAutoExpireCompletedTodos(u64),

    // Application Events
    CompletedTodoExpired,
    Tick(String),
}
