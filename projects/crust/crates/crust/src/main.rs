#![no_std]
#![no_main]

use core::{
    ffi::{c_char, c_int},
    panic::PanicInfo,
};

unsafe extern "C" {
    fn exit(status: c_int) -> !;
    fn printf(fmt: *const c_char, ...) -> c_int;
}

#[unsafe(no_mangle)]
extern "C" fn main() {
    unsafe {
        printf(c"Hello, %s!\n".as_ptr(), "Lars\0");
        exit(0);
    }
}

#[panic_handler]
fn panic_hanlder(_: &PanicInfo) -> ! {
    loop {}
}
