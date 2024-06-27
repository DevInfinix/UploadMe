#!/bin/bash

ROM=LOS-EXT
CLONE=1

rm -rf out/target/product/haydn/*.zip

if [ $CLONE == 1 ]; then

repo init --depth=1 --no-repo-verify -u https://github.com/Los-Ext/manifest.git -b lineage-21.0 --git-lfs  -g default,-mips,-darwin,-notdefault

# Sync source without unnecessary messages, try with -j30 first, if fails, it will try again
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync || repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync

# Leica patch
echo 'Adding Leica camera patch'
cd frameworks/base
wget https://raw.githubusercontent.com/xiaomi-haydn-devs/Patch-Haydn/14/Leicamera/0001-Add-backwards-compatible-CaptureResultExtras-constructor.patch
patch -p1 <0001-Add-backwards-compatible-CaptureResultExtras-constructor.patch
cd ../..

# device trees
git clone --depth=1 https://github.com/1xtAsh/device-xiaomi-haydn -b lineage-21 device/xiaomi/haydn
git clone --depth=1 https://github.com/1xtAsh/device-xiaomi-sm8350 -b lineage-21 device/xiaomi/sm8350-common
git clone --depth=1 https://github.com/1xtAsh/vendor-xiaomi-haydn -b lineage-21 vendor/xiaomi/haydn
git clone --depth=1 https://github.com/1xtAsh/vendor-xiaomi-sm8350 -b lineage-21 vendor/xiaomi/sm8350-common

# extra repo
git clone https://github.com/Los-Ext/vendor_lineage-priv_keys -b lineage-21.0 vendor/lineage-priv/keys
rm -rf hardware/xiaomi && git clone --depth=1 https://github.com/LineageOS/android_hardware_xiaomi -b lineage-21 hardware/xiaomi
git clone --depth=1 https://gitlab.com/Alucard_Storm/vendor_xiaomi_haydn-firmware.git -b fourteen vendor/xiaomi/haydn-firmware
git clone --depth=1 https://gitlab.com/Alucard_Storm/haydn-miuicamera.git -b fourteen-leica vendor/xiaomi/haydn-miuicamera
rm -rf hardware/xiaomi/megvii

fi

# Normal build steps
. build/envsetup.sh
lunch lineage_haydn-ap1a-userdebug

mka bacon -j$(nproc --all)

cd out/target/product/haydn/
ls *-eng*.zip && rm -rf *-eng*.zip
ls *-ota-*.zip && rm -rf *-ota-*.zip

# Public Release
REL=https://github.com/1xtAsh/BuildOS.git
gh release create $ROM --generate-notes --repo $REL
gh release upload --clobber $ROM *.zip --repo $REL

cd -
