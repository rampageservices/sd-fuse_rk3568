#!/bin/bash
set -eu

HTTP_SERVER=112.124.9.243

# hack for me
PCNAME=`hostname`
if [ x"${PCNAME}" = x"tzs-i7pc" ]; then
       HTTP_SERVER=127.0.0.1
fi

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_rk3568
cd sd-fuse_rk3568
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3568/old/kernel-5.10.y/images-for-eflasher/friendlycore-focal-arm64-images.tgz
tar xzf friendlycore-focal-arm64-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3568/old/kernel-5.10.y/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3568/rootfs/rootfs-friendlycore-focal-arm64.tgz

TEMPSCRIPT=`mktemp script.XXXXXX`
cat << 'EOL' > $PWD/$TEMPSCRIPT
#!/bin/bash
tar xzf rootfs-friendlycore-focal-arm64.tgz --numeric-owner --same-owner
echo hello > friendlycore-focal-arm64/rootfs/root/welcome.txt
./build-rootfs-img.sh friendlycore-focal-arm64/rootfs friendlycore-focal-arm64
EOL
chmod 755 $PWD/$TEMPSCRIPT
if [ $(id -u) -ne 0 ]; then
    ./tools/fakeroot-ng $PWD/$TEMPSCRIPT
else
    $PWD/$TEMPSCRIPT
fi
rm $PWD/$TEMPSCRIPT

./mk-sd-image.sh friendlycore-focal-arm64
./mk-emmc-image.sh friendlycore-focal-arm64
