bluebuild := require("bluebuild")

_default:
    @just --list

# remove ISO files from repository root
[confirm('Remove existing ISOs and their checksum files?')]
@clean-isos:
    rm -f {{ justfile_dir() }}/*.iso {{ justfile_dir() }}/*.iso-CHECKSUM

# build an ISO from the latest remote image
[arg('IMAGE', pattern='noiselab')]
build-image-iso IMAGE='noiselab': clean-isos
    sudo {{ bluebuild }} generate-iso --iso-name {{ justfile_dir() }}/{{ IMAGE }}.iso image ghcr.io/lotsospaghetti/{{ IMAGE }}:latest
    sudo chown ${USER}:${USER} {{ justfile_dir() }}/{{ IMAGE }}.iso {{ justfile_dir() }}/{{ IMAGE }}.iso-CHECKSUM

# build an ISO from local recipe
build-recipe-iso RECIPE='silverblue': clean-isos
    @if ! $(ls {{ justfile_dir() }}/recipes | grep -q '{{ RECIPE }}.yml'); then \
         echo '{{ style("error") + "A recipe named " + RECIPE + ".yml does not exist in the recipes directory!" + NORMAL }}'; exit 1; fi
    sudo {{ bluebuild }} generate-iso --iso-name {{ justfile_dir() }}/noiselab-{{ RECIPE }}.iso recipe {{ justfile_dir() }}/recipes/{{ RECIPE }}.yml
    sudo chown ${USER}:${USER} {{ justfile_dir() }}/noiselab-{{ RECIPE }}.iso {{ justfile_dir() }}/noiselab-{{ RECIPE }}.iso-CHECKSUM
