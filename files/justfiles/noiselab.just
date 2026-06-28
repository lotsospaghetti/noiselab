# Apply the realtime group to the current user
[group('system')]
add-user-to-realtime-group:
    sudo usermod -a -G realtime $(whoami)

# TODO: shortcuts for common realtime/audio benchmarks

# TODO: shortcut to disable wifi & bluetooth

# Shortcut for manually editing kernel arguments
[group('kernel')]
edit-kargs:
    sudo rpm-ostree kargs --editor

# TODO: CPU isolation kernel settings

# TODO: apply mitigations=off with a scary warning message

# TODO: shortcut for searching for and layering packages from ycollet/audinux COPR
