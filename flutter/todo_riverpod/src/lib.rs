use std::fmt::Display;

// -----------------
// Store
// -----------------
#[rid::model]
#[rid::structs(Todo)]
#[rid::enums(Filter)]
#[derive(Debug, rid::Debug)]
pub struct Store {
    last_added_id: u32,
    todos: Vec<Todo>,
    filter: Filter,
}

#[rid::export]
impl Store {
    fn create() -> Self {
        let first_todo = Todo {
            id: 0,
            title: "Learn Flutter".to_string(),
            completed: true,
        };
        let second_todo = Todo {
            id: 1,
            title: "Learn Rust".to_string(),
            completed: true,
        };
        let third_todo = Todo {
            id: 2,
            title: "Learn Rid".to_string(),
            completed: false,
        };
        let fourth_todo = Todo {
            id: 3,
            title: "Build Awesome Apps".to_string(),
            completed: false,
        };
        Self {
            last_added_id: 3,
            todos: vec![first_todo, second_todo, third_todo, fourth_todo],
            filter: Filter::All,
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
                };
                self.todos.push(todo);
                rid::post(Reply::AddedTodo(req_id, self.last_added_id.to_string()));
            }
            RemoveTodo(id) => {
                let mut enumerated = self.todos.iter().enumerate();
                let idx = match enumerated.find(|(_, todo)| todo.id == id) {
                    Some((idx, _)) => idx,
                    None => return eprintln!("Could not find Todo with id '{}'", id),
                };
                self.todos.remove(idx);
                rid::post(Reply::RemovedTodo(req_id, self.last_added_id.to_string()));
            }

            RemoveCompleted => {
                self.todos.retain(|todo| !todo.completed);
                rid::post(Reply::RemovedCompleted(req_id));
            }

            ToggleTodo(id) => {
                self.update_todo(id, |todo| todo.completed = !todo.completed);
                rid::post(Reply::ToggledTodo(req_id, id.to_string()));
            }

            CompleteAll => {
                self.todos.iter_mut().for_each(|x| x.completed = true);
                rid::post(Reply::CompletedAll(req_id));
            }
            RestartAll => {
                self.todos.iter_mut().for_each(|x| x.completed = false);
                rid::post(Reply::RestartedAll(req_id));
            }

            SetFilter(filter) => {
                self.filter = filter;
                rid::post(Reply::SetFilter(req_id));
            }
        };
    }

    fn update_todo<F: FnOnce(&mut Todo)>(&mut self, id: u32, update: F) {
        match self.todos.iter_mut().find(|x| x.id == id) {
            Some(todo) => update(todo),
            None => eprintln!("Could not find Todo with id '{}'", id),
        };
    }

    #[rid::export]
    #[rid::structs(Todo)]
    fn filtered_todos(&self) -> Vec<&Todo> {
        let mut vec: Vec<&Todo> = match self.filter {
            Filter::Completed => self.todos.iter().filter(|x| x.completed).collect(),
            Filter::Pending => self.todos.iter().filter(|x| !x.completed).collect(),
            Filter::All => self.todos.iter().collect(),
        };
        vec.sort();
        vec
    }
}

// -----------------
// Todo Model
// -----------------
#[rid::model]
#[derive(Debug, rid::Debug, PartialEq, Eq, PartialOrd, rid::Display)]
pub struct Todo {
    id: u32,
    title: String,
    completed: bool,
}

impl Ord for Todo {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.id.cmp(&other.id)
    }
}

impl Display for Todo {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let status = if self.completed { "✓" } else { " " };
        write!(f, "[{}] ({}) '{}'", status, self.id, self.title)
    }
}

// -----------------
// Filter
// -----------------
#[derive(Clone, Debug, rid::Debug, rid::Display)]
#[repr(C)]
pub enum Filter {
    Completed,
    Pending,
    All,
}

impl Display for Filter {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Filter::Completed => write!(f, "Completed"),
            Filter::Pending => write!(f, "Pending"),
            Filter::All => write!(f, "All"),
        }
    }
}

// -----------------
// Msg
// -----------------
#[rid::message(Store, Reply)]
#[rid::enums(Filter)]
#[derive(Debug)]
pub enum Msg {
    AddTodo(String),
    RemoveTodo(u32),
    RemoveCompleted,

    ToggleTodo(u32),
    CompleteAll,
    RestartAll,

    SetFilter(Filter),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    AddedTodo(u64, String),
    RemovedTodo(u64, String),
    RemovedCompleted(u64),

    ToggledTodo(u64, String),
    CompletedAll(u64),
    RestartedAll(u64),

    SetFilter(u64),
}
