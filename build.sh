# Removals
rm -rf device/xiaomi/haydn

# Initialize repo with specified manifest
repo init -u https://github.com/ProjectMatrixx/android.git -b 14.0 --git-lfs --depth=1

# Clone device tree
git clone https://github.com/1xtAsh/device-xiaomi-haydn -b crave device/xiaomi/haydn

# Sync the repositories
/opt/crave/resync.sh

# Private Keys
rm -rf vendor/lineage-priv/keys && git clone https://github.com/1xtAsh/vendor_lineage-priv_keys -b lineage-21 vendor/lineage-priv/keys

# Set up build environment
source build/envsetup.sh

# Cleanup directories
make installclean

# Git-lfs
repo forall -c 'git lfs install && git lfs pull && git lfs checkout'

# Build
brunch haydn
