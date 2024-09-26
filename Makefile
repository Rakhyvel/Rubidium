# TODO: Remake this as a python build script
BSP ?= rpi3

KERNEL_BIN = kernel8.img
TARGET = aarch64-unknown-none-softfloat
KERNEL_ELF = target/$(TARGET)/release/kernel
KERNEL_MANIFEST = Cargo.toml
LAST_BUILD_CONFIG = target/$(BSP).build_config
KERNEL_ELF_DEPS = $(filter-out %: ,$(file < $(KERNEL_ELF).d)) $(KERNEL_MANIFEST) $(LAST_BUILD_CONFIG)
RUSTC_CMD = cargo rustc $(COMPILER_ARGS)
RUSTC_MISC_ARGS   = -C target-cpu=cortex-a53
LD_SCRIPT_PATH    = $(shell pwd)/src/bsp/raspberrypi
KERNEL_LINKER_SCRIPT = kernel.ld
RUSTFLAGS = $(RUSTC_MISC_ARGS)                   \
    -C link-arg=--library-path=$(LD_SCRIPT_PATH) \
    -C link-arg=--script=$(KERNEL_LINKER_SCRIPT)
FEATURES      = --features bsp_$(BSP)
COMPILER_ARGS = --target=$(TARGET) \
    $(FEATURES)                    \
    --release
RUSTFLAGS_PEDANTIC = $(RUSTFLAGS) \
    -D warnings                   \
    -D missing_docs

all: $(KERNEL_BIN)

$(KERNEL_BIN): $(KERNEL_ELF)
	llvm-objcopy --strip-all -O binary $(KERNEL_ELF) $(KERNEL_BIN)

$(KERNEL_ELF): $(KERNEL_ELF_DEPS)
	RUSTFLAGS="$(RUSTFLAGS_PEDANTIC)" $(RUSTC_CMD)
	
$(LAST_BUILD_CONFIG):
	@rm -f target/*.build_config
	@mkdir -p target
	@touch $(LAST_BUILD_CONFIG)