mod reddit;
#[rid::export]
pub fn hello_world(id: u8) -> String {
    rid::log_info!("Providing hello world for {}", id);
    "hello world".to_string()
}
