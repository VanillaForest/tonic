# Linux build kit

This is useful if you want to quickly create a bootable rootfs from scratch.
If you need something like this, try [buildroot](https://buildroot.org/) instead.

# Building

An musl toolchain is required for building tonic.
The musl libc itself can be configured to install an musl-gcc wrapper script, which can be used to compile tonic without having a full musl toolchain installed.

## Configuring

Copy `config.mk.def` over to `config.mk` and edit it to match your toolchain settings.
The directives follow the usual compilation logic:

- The `CC` setting names your gcc name. Typical values would be `gcc` for native (musl-host) compiling, `musl-gcc` for native architecture but cross-libc, and `x86_64-linux-musl-gcc` for cross-compiling
- `CROSS_COMPILE` is the prefix for buildchain tools like objdump. It is usually empty for native arch builds and end with an hyphen for cross-compiling
- `CFLAGS` contains your optimisation levels and whether to include symbol tables (for gdb debugging) into your binaries
- `LDFLAGS` contain the linker flags as given to `$CC`. Since the required flags are already added by the Makefile, you can leave this empty if you do not want to build statically
- `THREADS` is the number of parallel build threads. If you put a high number here your build will be faster, at the cost of making it less responsive.

## Getting the sources

If you want to download the sources first and compile offline, you can issue `make sources` to trigger the downloads.
Sources will be downloaded on-demand if you skip this.

## Compiling

A plain `make` will compile `bin/busybox` and `bin/mksh` and auxillary files of those.
Dependency management is done via build target dependencies of the top-level makefile.

Please not that most packages are quite experimental and will likely break, depending on your configuration.
For example, the upstream build system of `LVM2` deals really bad with static linking.

## Testing

`make chroot` allows you to enter your target system.

## Pack into image

Currently there is an target for `make boot/tonic.cpio.xz` which will generate an initramfs from the build artifacts.
Feel free to implement your own mechamism here or just pick the binaries manually from bin/.
