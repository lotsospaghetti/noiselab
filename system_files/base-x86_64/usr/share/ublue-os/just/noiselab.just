# vim: set ft=make :

# Install System Flatpaks (Support for Rebasing)
_install-system-flatpaks:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    # TODO: get image name from info file
    FLATPAKS="base/flatpaks"
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/lotsospaghetti/noiselab/main/installer/${FLATPAKS} | tr '\n' ' ')"
    flatpak --system -y install --reinstall --or-update ${FLATPAK_LIST}

# Pull latest noisebox image (https://github.com/lotsospaghetti/noisebox)
_pull-noisebox:
    #!/usr/bin/bash
    distrobox assemble create --replace --file /etc/distrobox/noisebox.ini --name noisebox

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
    done

# Install Renoise, a nonfree music-tracker DAW. Requires you to download the installer from https://backstage.renoise.com
[group("apps")]
install-renoise INSTALLER="":
    #!/usr/bin/bash
    if [[ "$INSTALLER" == "" ]]; then
        INSTALLER=$(zenity --file-selection --file-filter='Renoise x86_64 installer archive (tar.gz) | rns_*_linux_x86_64.tar.gz' --title="Choose Renoise installer archive" --filename=~/)
    fi

    if [[ ! "$(basename $INSTALLER)" =~ "rns_.*_linux_x86_64.tar.gz" ]]; then
        echo "No valid installer archive selected, exiting..."
        exit 1
    fi

    INSTALLER_PATH=$(dirname $INSTALLER) INSTALLER_ARCHIVE=$(basename $INSTALL) \
        distrobox-assemble create --replace --file /etc/distrobox/renoise.ini

# Install additional apps using noisebox, the Distrobox companion to noiselab
[group("apps")]
install-noisebox-apps APPS="":
    #!/usr/bin/bash
    # TODO: iterate over distroboxes in noisebox.ini presenting user with a multi-selectable list and build selections

# Enable support for Tailscale
[group("network")]
enable-tailscale:
    systemctl enable --now tailscaled.service
