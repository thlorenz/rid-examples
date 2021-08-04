// https://radu-matei.com/blog/practical-guide-to-wasm-memory/
// https://github.com/rustwasm/wasm-bindgen/blob/eb855e3fd48188bef6bbea8180102f5fe550a0e5/src/lib.rs#L969-L1026

// TODO: look into this hack to get it included in the binary (possibly also into bindings?)
// https://github.com/rustwasm/wasm-bindgen/blob/eb855e3fd48188bef6bbea8180102f5fe550a0e5/src/lib.rs#L1028-L1063
mod __rid_malloc_methods {
    use std::alloc::{alloc, dealloc, realloc, Layout};
    use std::mem;

    #[no_mangle]
    pub extern "C" fn rid_malloc(size: usize) -> *mut u8 {
        let align = mem::align_of::<usize>();
        if let Ok(layout) = Layout::from_size_align(size, align) {
            unsafe {
                if layout.size() > 0 {
                    let ptr = alloc(layout);
                    if !ptr.is_null() {
                        return ptr;
                    }
                } else {
                    return align as *mut u8;
                }
            }
        }

        malloc_failure();
    }

    #[no_mangle]
    pub unsafe extern "C" fn rid_realloc(
        ptr: *mut u8,
        old_size: usize,
        new_size: usize,
    ) -> *mut u8 {
        let align = mem::align_of::<usize>();
        debug_assert!(old_size > 0);
        debug_assert!(new_size > 0);
        if let Ok(layout) = Layout::from_size_align(old_size, align) {
            let ptr = realloc(ptr, layout, new_size);
            if !ptr.is_null() {
                return ptr;
            }
        }
        malloc_failure();
    }

    #[cold]
    fn malloc_failure() -> ! {
        std::process::abort();
    }

    #[no_mangle]
    pub unsafe extern "C" fn rid_free(ptr: *mut u8, size: usize) {
        // This happens for zero-length slices, and in that case `ptr` is
        // likely bogus so don't actually send this to the system allocator
        if size == 0 {
            return;
        }
        let align = mem::align_of::<usize>();
        let layout = Layout::from_size_align_unchecked(size, align);
        dealloc(ptr, layout);
    }
}
