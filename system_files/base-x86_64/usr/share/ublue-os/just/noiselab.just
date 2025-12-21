# vim: set ft=make :

# Install System Flatpaks (Support for Rebasing)
_install-system-flatpaks:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    # TODO: get image name from info file
    FLATPAKS="base/flatpaks"
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/lotsospaghetti/noiselab/main/installer/${FLATPAKS} | tr '\n' ' ')"
    flatpak --system -y install --reinstall --or-update ${FLATPAK_LIST}

# Add user to various audio groups required for optimal performance, as well as input and libvirt groups
[group("system")]
add-user-to-groups:
    #!/usr/bin/bash
    for g in \
        audio \
        realtime \
        jackuser \
        pipewire \
        input \
        libvirt; \
    do
        if ! grep -q "^$g" /etc/group; then
            sudo bash -c 'grep "^$g" /lib/group >> /etc/group'
        fi
        sudo usermod -a -G "$g" $USER
