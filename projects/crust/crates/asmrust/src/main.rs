#![no_std]
#![no_main]

use core::{arch::asm, panic::PanicInfo};

fn exit(status: i32) -> ! {
    unsafe {
        asm!(
            "syscall",
            in("rax") 60,
            in("rdi") status,
        );
    }
    loop {}
}

fn write(fd: i32, bytes: &[u8]) {
    unsafe {
        asm!(
            "syscall",
            in("rax") 1,
            in("rdi") fd,
            in("rsi") bytes.as_ptr(),
            in("rdx") bytes.len(),
        )
    }
}

#[unsafe(no_mangle)]
extern "C" fn _start() {
    write(1, b"Hello, Lars!\n");
    exit(69);
}

#[panic_handler]
fn panic_handler(_: &PanicInfo) -> ! {
    loop {}
}
