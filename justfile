bluebuild := require("bluebuild")
export BB_REGISTRY := 'ghcr.io'
export BB_REGISTRY_NAMESPACE := 'lotsospaghetti'
export BB_GENISO_SECURE_BOOT_URL := 'https://github.com/blue-build/base-images/raw/refs/heads/main/files/base/etc/pki/akmods/certs/akmods-blue-build.der'
export BB_GENISO_ENROLLMENT_PASSWORD := 'bluebuild'
export BB_GENISO_VARIANT := 'kionite'

_default:
    @just --list

# remove any non-tracked files from repository root
@clean:
    find -type f -regex '.*.iso\(\-CHECKSUM\)?' -delete
    rm -rf .bluebuild-scripts_*

# shortcut for 'bluebuild build'
build *ARGS: clean
    {{ bluebuild }} build {{ ARGS }}

# shortcut for building all recipes
build-all: (build "recipes/*.yml")

# create an ISO from the latest remote image
generate-registry-iso IMAGE='noiselab' TAG='latest' PLATFORM='amd64': clean
    {{ bluebuild }} generate-iso --platform 'linux/{{ PLATFORM }}' --iso-name '{{ IMAGE }}-{{ TAG }}.iso' image "${BB_REGISTRY}/${BB_REGISTRY_NAMESPACE}/{{ IMAGE }}:{{ TAG }}"

# create an ISO from a recipe
generate-recipe-iso RECIPE='silverblue' PLATFORM='amd64': clean
    {{ bluebuild }} generate-iso --platform 'linux/{{ PLATFORM }}' --iso-name 'noiselab-{{ RECIPE }}.iso' recipe 'recipes/{{ RECIPE }}.yml'

# write a bootable installer to removable storage
write-usb-install-media ISO='noiselab-latest.iso':
    #!/usr/bin/env sh
    set -euo pipefail
    if ! [ -f '{{ ISO }}' ]; then
        echo '{{ style('error') }}ISO file "{{ ISO }}" not found{{ NORMAL }}'
        exit 1
    fi
    declare -a removable_drives
    for dev in $(ls /sys/block); do
        if [ $(cat /sys/block/${dev}/removable) -eq 1 ] && \
            [ $(sudo lsblk /dev/${dev} --output SIZE --bytes --nodeps --noheadings) -gt $(ls -s '{{ ISO }}' | cut -d' ' -f1) ]; then
            removable_drives+=("/dev/$dev ($(sudo lsblk /dev/sdd --output VENDOR,MODEL --nodeps --noheadings | xargs))")
        fi
    done
    if [ "${removable_drives}" == '' ]; then
        echo '{{ style('error') }}No removable drives large enough to fit ISO contents were found{{ NORMAL }}'
        exit 1
    fi
    target="$(gum choose --header='Select removable drive to write ISO contents to:' "${removable_drives[@]}")"
    target="$(echo "${target}" | cut -d'(' -f 1 | xargs)"
    if ! gum confirm "Are you sure you'd like to overwrite drive $target?"; then
        echo 'Operation canceled' && exit 0; fi
    echo "Writing contents of '{{ ISO }}' to drive ${target}..."
    for mp in $(lsblk "$target" --output MOUNTPOINTS --noheadings); do
        sudo umount -qf "$mp" || exit 1; done
    sudo dd if='{{ justfile_dir() }}/{{ ISO }}' of="$target" bs=4M conv=fsync oflag=direct status=progress
    echo 'Done'
