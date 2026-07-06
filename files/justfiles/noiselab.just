# Apply the necessary groups to the current user
[group('system')]
add-user-groups:
    sudo usermod -aG realtime,rtkit,gamemode $(whoami)
    sudo usermod -aG pipewire $(whoami) &>/dev/null || true
    sudo usermod -aG jackuser $(whoami) &>/dev/null || true

# Completely remove Brew remnants, if rebased from an image that had it
[group('system')]
remove-brew:
    #!/usr/bin/env bash
    if [[ -d "${HOME}/cache/Homebrew/" ]]; then
      echo "Removing '$HOME/cache/Homebrew/' directory"
      rm -r "${HOME}/cache/Homebrew/"
    else
      echo "'${HOME}/cache/Homebrew/' directory is already removed"
    fi
    if [[ -d "/var/lib/homebrew/" ]]; then
      echo "Removing '/var/lib/homebrew/' directory"
      sudo rm -rf "/var/lib/homebrew/"
    else
      echo "'/var/lib/homebrew/' directory is already removed"
    fi
    if [[ -d "/var/cache/homebrew/" ]]; then
      echo "Removing '/var/cache/homebrew/' directory"
      sudo rm -rf "/var/cache/homebrew/"
    else
      echo "'/var/cache/homebrew/' directory is already removed"
    fi
    ## This is the main directory where brew is located
    if [[ -d "/var/home/linuxbrew/" ]]; then
      echo "Removing '/home/linuxbrew/' directory"
      sudo rm -rf "/var/home/linuxbrew/"
    else
      echo "'/home/linuxbrew/' directory is already removed"
    fi
    if [[ -f "/etc/.linuxbrew" ]]; then
      echo "Removing empty '/etc/.linuxbrew' file"
      sudo rm -f "/etc/.linuxbrew"
    else
      echo "'/etc/.linuxbrew' file is already removed"
    fi

# Enable or disable gamemoded service
[arg('ACTION', pattern='enable|disable')]
[group('system')]
gamemode-service ACTION='enable':
    systemctl --user {{ ACTION }} --now gamemoded.service

# TODO: shortcuts for common realtime/audio benchmarks

# Enable or disable wifi and bluetooth via service masking
[arg('ACTION', pattern='enable|disable')]
[group('system')]
wireless-service ACTION='disable':
    sudo systemctl {{ ACTION }} --now NetworkManager.service
    sudo systemctl {{ ACTION }} --now bluetooth.service
    # TODO: add/remove module_blacklist=<WIFI>,<BLUETOOTH> to kargs

# Shortcut for manually editing kernel arguments
[group('kernel')]
edit-kargs:
    sudo rpm-ostree kargs --editor

# TODO: CPU isolation kernel settings

# Enable or disable kernel mitigations
[arg('ACTION', pattern='enable|disable')]
[group('kernel')]
edit-mitigations ACTION='enable':
    #!/usr/bin/env bash
    if [[ '{{ ACTION }}' == 'disable' ]]; then
        echo "{{ style('warning') }}This action will add the 'mitigations=off' kernel argument, which will improve system performance{{ NORMAL }}"
        echo "{{ style('error') }}BUT AT THE COST OF MAKING YOUR SYSTEM SIGNIFICANTLY LESS SECURE!!!{{ NORMAL }}"
        echo "{{ style('warning') }}You should ONLY EVER do this on fully offline systems dedicated to realtime audio work!{{ NORMAL }}"
        echo "{{ style('warning') }}This script will automatically drop all network connections and disable wireless before applying the karg.{{ NORMAL }}"
        echo
        if ! gum confirm 'Are you sure you'd like to proceed?'; then
            echo 'No action taken.'
            exit 0
        fi
        sudo firewall-cmd --panic-on
        ujust wireless-service disable
        sudo rpm-ostree kargs --delete-if-present=mitigations=auto
        sudo rpm-ostree kargs --delete-if-present=mitigations=auto,nosmt
        sudo rpm-ostree kargs --append-if-missing=mitigations=off
    elif [[ '{{ ACTION }}' == 'enable' ]]; then
        sudo rpm-ostree kargs --delete-if-present=mitigations=off
        sudo rpm-ostree kargs --delete-if-present=mitigations=auto,nosmt
        sudo rpm-ostree kargs --append-if-missing=mitigations=auto
    fi

# Shortcut for searching and layering packages from ycollet/audinux COPR
[group('packages')]
add-audinux-packages QUERY='':
    #!/usr/bin/env bash
    QUERY='{{ QUERY }}'
    if [[ "$QUERY" != '' ]]; then QUERY="\*${QUERY}\*"; fi
    PKGS="$(dnf repoquery --exclude *-debug*,license-*,bluez-*,linux-*,yabridge-*,wine* \
        --repoid=copr:copr.fedorainfracloud.org:ycollet:audinux --arch=$(uname -m) --available --queryformat "%{name} - %{summary}\n" "$QUERY" 2>/dev/null | \
        gum choose --no-limit | awk '{print $1}' | xargs)"
    sudo rpm-ostree install "${PKGS[@]}"

# Make yabridge aware of plugins installed to a bottle
[group('wine')]
add-plugins-from-bottle BOTTLE PATH='/drive_c/Program Files/Common Files/VST3':
    yabridgectl add "${HOME}/.local/share/bottles/bottles/{{ BOTTLE }}{{ PATH }}" && yabridgectl sync

# Shortcut for paging through packages installed or layered in booted image
[group('development')]
list-installed-packages:
    sudo dnf list --installed | less
