## Pre-requisites
```sh
# Install toolchain
rustup target add aarch64-unknown-none-softfloat

# Install cargo binutils
cargo install cargo-binutils
rustup component add llvm-tools
```