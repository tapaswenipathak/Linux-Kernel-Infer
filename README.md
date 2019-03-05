## Infer on Linux Kernel

This document contains instructions to run infer on Linux Kernel. This documents
has instructions to run infer version 0.14.0 and 0.15.0, Clang version
3.8.0, 6.0 and 7.0 on kernel staging and current run with allnoconfig,
allmodconfig, allyesconfig, defconfig.

### Machine and Packages Version Specifics

1. OS information

```sh
lsb_release -a
Distributor ID: Ubuntu
Description:  Ubuntu 18.10 LTS
Release:  18.10
Codename: cosmic

```

2. Infer version information

```sh
infer --version
Infer version v0.15.0-832e013

```

3. Clang version information

```sh
clang --version
clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/bin

```

4. Kernel version

  - [5.0.rc-8 tree](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/)
  - [staging tree](https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git)


5. Kernel compilation comfiguration

  - defconfig
	- allnoconfig
	- allyesconfig
	- allmoconfig

6. CMake version

```sh
cmake --version
cmake version 3.5.1
```

7. GCC version

```sh
gcc --version
gcc (Ubuntu 8.1.0-5ubuntu1~16.04) 8.1.0
```
#### Docker setup

[Dockerfile](./Dockerfile)

### Installations

1. Installing Infer

  - Install [infer dependencies for linux](https://github.com/facebook/infer/blob/master/INSTALL.md#infer-dependencies-for-linux), few packages to be installed are present in the Dockerfile
    - Install cmake using `sudo apt install cmake`
  - clone infer using `git clone git@github.com:facebook/infer.git`
  - Compile infer: `./build-infer.sh`
  - Install infer: `sudo apt install infer`
  - To run Infer on kernel few directories have to be added to skipped in the code
    - vim `infer/src/clang/cLocation.ml`
    - Replace `let paths = Config.skip_analysis_in_path in` with
      ```
      let paths = ["[<directory>/git/staging/arch/x86";"<directory>/git/staging/arch/x86/entry/vdso";"<directory>/git/    staging/arch/x86/kernel";"<directory>/git/staging/arch/x86/boot";"<directory>/git/staging/arch/mm";"<directory>/g    it/staging/mm";"<directory>/git/staging/drivers/acpi";"<directory>/git/staging/fs";"<directory>/git/staging/kerne    l/bpf";"<directory>/git/staging/net/mac80211"] in

      ```

    or apply [this]() patch with `git apply <patch-name>`

  - To install after any code changes:
    ```sh
    make clean
    make or ./build-install.sh
    make install
    ```
 - The make can run out of core even with make (without a -j n) at the stage of building
 Clang as that is very memory intensive. After multiple runs infer build stops at > 95%
 if runs out of cores in a system as during that phase facebook/facebook-clang-plugins
   are installed. Change [this](https://github.com/facebook/facebook-clang-plugins/blob/master/clang/setup.sh#L16-L17)
   line to hardcode it to run one core since the start so that it can utilize cores
   at installing clang phase.

There should be no errors.

2. Kernel setup

  - Clone kernel trees linked above
  - Install libelf-dev `sudo apt-get install libelf-dev`
  - Install libssl-dev `sudo apt-get install libssl-dev`
  - Clang should be set as default compiler to run infer capture. As Linux Makefiles
  uses gcc and infer compiles with Clang, compiler flag in the Makefile should be using
  Clang. Add below lines to the Makefile

  ```
  override CC=clang
  override HOSTCC=clang
  ```
  or apply [this]() patch to setup compilation using Clang.
  - asm-goto check error on gcc-8.1 and clang 6.0 when it supposed to be just limiting anything before [gcc-4.5](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e501ce957a786ecd076ea0cfb10b114e6e4d0f40).
  - Apply [this]() patch to delete the asm goto check in compiler or update the Makefile
  in and `arch/x86` Makefile per the above patch.

### Running Infer on kernel

1. `cd <linux-kernel-directory>`
2. `make clean && make defconfig`
3. `infer capture -- make`
4. After completion of above command, run `infer analyze`. Infer creates a infer-out
folder. Running the command takes a lot of time and need huge computing power.
5. Find reports in cat /infer-out/bugs.txt, finds the reports from this setup [here](./reports/)

### To setup multiple versions of Infer

There are few code changes in the `./configure` script in Infer to use `pkg-config`,
apply [this]() patch to setup.

## Patches

You can find the patches applied on current version on the tree. Patches (Sent, Applied,
Acked, Appoved) are present in kernel-infer-patches dir.
