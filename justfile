bluebuild := require("bluebuild")
export BB_REGISTRY := 'ghcr.io'
export BB_REGISTRY_NAMESPACE := 'lotsospaghetti'
export BB_GENISO_SECURE_BOOT_URL := 'https://github.com/blue-build/base-images/raw/refs/heads/main/files/base/etc/pki/akmods/certs/akmods-blue-build.der'
export BB_GENISO_ENROLLMENT_PASSWORD := 'bluebuild'
export BB_GENISO_VARIANT := 'kionite'

@_default:
    just --list

@_clean-buildscripts:
    rm -rf .bluebuild-scripts_*

@_clean-isos:
    rm -rf .iso/
    find -type f -regex '.*.iso\(\-CHECKSUM\)?' -delete

[arg('EXECUTABLE', pattern='docker|podman|buildah')]
@_clean-images EXECUTABLE='docker':
    command -v '{{ EXECUTABLE }}' >/dev/null 2>/dev/null && \
    '{{ EXECUTABLE }}' rmi --force $('{{ EXECUTABLE }}' images --format "{{{{.ID}} {{{{$(if [ '{{ EXECUTABLE }}' == 'buildah' ]; then echo '.Name'; else echo '.Repository'; fi)}}" | \
    grep "${BB_REGISTRY}/${BB_REGISTRY_NAMESPACE}/noiselab" | cut -d' ' -f1) >/dev/null 2>&1 || true

# remove any non-tracked files from repository root
[confirm('This will delete all generated images and ISO media. Continue?')]
clean: _clean-buildscripts _clean-isos (_clean-images "docker") (_clean-images "podman") (_clean-images "buildah")

# shortcut for 'bluebuild build'
build *ARGS: _clean-buildscripts
    {{ bluebuild }} build {{ ARGS }}

# shortcut for building all recipes
build-all: (build "recipes/*.yml")

@_create-iso-dir:
    mkdir .iso >/dev/null 2>&1 || true

# create an ISO from an image
generate-registry-iso IMAGE='noiselab' TAG='latest' PLATFORM='amd64': _create-iso-dir
    {{ bluebuild }} generate-iso --output-dir .iso/ --platform 'linux/{{ PLATFORM }}' --iso-name '{{ IMAGE }}-{{ TAG }}.iso' image "${BB_REGISTRY}/${BB_REGISTRY_NAMESPACE}/{{ IMAGE }}:{{ TAG }}"

# create an ISO from a recipe
generate-recipe-iso RECIPE='silverblue' PLATFORM='amd64': _create-iso-dir
    {{ bluebuild }} generate-iso --output-dir .iso/ --platform 'linux/{{ PLATFORM }}' --iso-name 'noiselab-{{ RECIPE }}.iso' recipe 'recipes/{{ RECIPE }}.yml'

# write a bootable installer to removable storage
[working-directory('.iso')]
write-usb-install-media ISO='noiselab-latest.iso': _create-iso-dir
    #!/usr/bin/env sh
    set -eo pipefail
    # sanity check: ISO checksum file exists and matches the given ISO
    if ! [ -f '{{ ISO }}-CHECKSUM' ] || ! sha256sum -check -quiet '{{ ISO }}-CHECKSUM' 2>/dev/null; then
        echo '{{ style('error') }}Checksum of ISO file {{ ISO }} not valid, or {{ ISO }}-CHECKSUM not found{{ NORMAL }}'
        exit 1
    fi
    # enumerate drives with the 'removable' property, to be selected by the user
    # drives show up in menu as '/dev/<DRIVE> (VENDOR MODEL)', since /dev/<DRIVE> by itself gives no useful info to the user
    # string substitution is then used outside confirmation dialogs to strip vendor info from this selection
    for dev in $(ls /sys/block); do
        if [ $(cat "/sys/block/${dev}/removable") -eq 1 ]; then
            removable_drives+=("/dev/${dev} ($(sudo lsblk "/dev/${dev}" --output VENDOR,MODEL --raw --nodeps --noheadings | sed 's/\\x20//g'))")
        fi
    done
    if [ "${removable_drives}" == '' ]; then
        echo '{{ style('error') }}No removable drives were found{{ NORMAL }}'
        exit 1
    fi
    target="$(gum choose --header='Select removable drive to write ISO contents to:' "${removable_drives[@]}" || exit 0)"
    if [ $(sudo lsblk "${target%%\ *}" --output SIZE --bytes --nodeps --noheadings) -lt $(ls -s '{{ ISO }}' | cut -d' ' -f1) ]; then
        echo "{{ style('error') }}Selected drive ${target} does not have enough storage capacity for file {{ ISO }}{{ NORMAL }}"
        exit 1
    fi
    if ! gum confirm "Are you sure you'd like to overwrite drive ${target}?"; then
        echo 'Operation canceled' && exit 0; fi
    echo "{{ style('warning') }}Writing contents of {{ ISO }} to drive ${target}...{{ NORMAL }}"
    for mp in $(lsblk "${target%%\ *}" --output MOUNTPOINTS --noheadings); do
        sudo umount -qf "${mp}" || exit 1; done
    sudo dd if='{{ ISO }}' of="${target%%\ *}" bs=4M conv=fsync oflag=direct status=progress
    echo 'Done'
