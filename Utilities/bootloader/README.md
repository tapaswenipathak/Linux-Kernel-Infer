# Bootloader

A bootloader for Linux.

# Dependencies

* Bash (tested with 4.3.48)
* GNU coreutils (Version: 8.25-2ubuntu3~16.04)
* kexec-tools (Version: 2.0.17)
* Linux

# Installation

## From source

1. `git clone git@github.com:tapasweni-pathak/linux-kernel.git`
2. `cd linux-kernel/Utilities/bootloader/Script`
3. `sudo cp bootloader.sh to /usr/local/bin`
4. `sudo cp bootloader.sh /usr/local/bin/bootloader`
5. `sudo chown root:root /usr/local/bin/bootloader`
6. `sudo chmod 755 /usr/local/bin/bootloader`

## From apt-get install package

1. `sudo apt install bootloader`

## From .deb package

1. `git clone git@github.com:tapasweni-pathak/linux-kernel.git`
2.  Install package from linux-kernel/Utilities/bootloader/Package

# Usage

1. bootloader -h prints help.
2. bootloader -v prints version.
3. sudo bootloader -l loads a kernel.
