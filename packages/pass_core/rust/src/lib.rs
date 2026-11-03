pub mod api;
pub mod format;
#[allow(unsafe_code)]
mod frb_generated;
mod storage;

// Native Assets resolves this anchor; dladdr identifies that exact loaded library.
#[unsafe(no_mangle)]
#[allow(unsafe_code)]
pub extern "C" fn want_pass_vault_library_path() -> *const libc::c_char {
    let mut info = std::mem::MaybeUninit::<libc::Dl_info>::zeroed();
    // The address belongs to this module; dladdr owns the returned path until unload.
    unsafe {
        if libc::dladdr(
            want_pass_vault_library_path as *const () as *const libc::c_void,
            info.as_mut_ptr(),
        ) == 0
        {
            return std::ptr::null();
        }
        info.assume_init().dli_fname
    }
}
