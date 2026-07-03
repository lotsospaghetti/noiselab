bluebuild := require("bluebuild")
export BB_GENISO_SECURE_BOOT_URL := 'https://github.com/blue-build/base-images/raw/refs/heads/main/files/base/etc/pki/akmods/certs/akmods-blue-build.der'
export BB_GENISO_ENROLLMENT_PASSWORD := 'bluebuild'

_default:
    @just --list

# remove ISO files from repository root
[confirm('Remove existing ISOs and their checksum files?')]
@clean-isos:
    rm -f {{ justfile_dir() }}/*.iso {{ justfile_dir() }}/*.iso-CHECKSUM

# build an ISO from the latest remote image
[arg('IMAGE', pattern='noiselab')]
[arg('PLATFORM', pattern='amd64|arm64')]
build-image-iso IMAGE='noiselab' PLATFORM='amd64': clean-isos
    sudo {{ bluebuild }} generate-iso --platform 'linux/{{ PLATFORM }}' --output-dir {{ justfile_dir() }} --iso-name {{ IMAGE }}.iso image ghcr.io/lotsospaghetti/{{ IMAGE }}:latest
    sudo chown ${USER}:${USER} {{ justfile_dir() }}/{{ IMAGE }}.iso {{ justfile_dir() }}/{{ IMAGE }}.iso-CHECKSUM

# build an ISO from local recipe
[arg('PLATFORM', pattern='amd64|arm64')]
build-recipe-iso RECIPE='silverblue' PLATFORM='amd64': clean-isos
    @if ! $(ls {{ justfile_dir() }}/recipes | grep -q '{{ RECIPE }}.yml'); then \
         echo '{{ style("error") + "A recipe named " + RECIPE + ".yml does not exist in the recipes directory!" + NORMAL }}'; exit 1; fi
    sudo {{ bluebuild }} generate-iso --platform 'linux/{{ PLATFORM }}' --output-dir {{ justfile_dir() }} --iso-name noiselab-{{ RECIPE }}.iso recipe {{ justfile_dir() }}/recipes/{{ RECIPE }}.yml
    sudo chown ${USER}:${USER} {{ justfile_dir() }}/noiselab-{{ RECIPE }}.iso {{ justfile_dir() }}/noiselab-{{ RECIPE }}.iso-CHECKSUM
