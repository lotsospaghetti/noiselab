# Apply the realtime group to the current user
[group('system')]
add-user-to-realtime-group:
    sudo usermod -a -G realtime $(whoami)

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

# TODO: shortcuts for common realtime/audio benchmarks

# TODO: shortcut to disable wifi & bluetooth

# Shortcut for manually editing kernel arguments
[group('kernel')]
edit-kargs:
    sudo rpm-ostree kargs --editor

# TODO: CPU isolation kernel settings

# TODO: apply mitigations=off with a scary warning message

# TODO: shortcut for searching for and layering packages from ycollet/audinux COPR
