#!/usr/bin/env bash

VER="linux-4.19"

tar -xvzf ${SRC}.tar.gz && cd ${SRC}
make defconfig
cat <<EOF >.config-fragment
EOF

./scripts/kconfig/merge_config.sh .config .config-fragment
time make -j"$(nproc)"

cd arch/x86_64/boot/
mkinitramfs -o initrd.img
qemu-img create disk_img.ext4 4G && mkfs -t ext4 disk_img.ext4

echo "init qemu"
qemu-system-x86_64 -S -s \
    -kernel arch/x86_64/boot/bzImage \
    -initrd initrd.img \
    -hda disk_img.ext4 \
    -append "root=/dev/sda rw" &
    make clean
