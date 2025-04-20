fn main() {
    // println!("cargo:rustc-link-lib=c")
    println!("cargo:rustc-link-arg=-nostartfiles");
    // println!("cargo:rustc-flags=-Ctarget-feature=+nocrt-static");
}
