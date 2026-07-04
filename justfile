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
