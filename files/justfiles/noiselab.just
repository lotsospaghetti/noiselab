# Apply the necessary groups to the current user
[group('system')]
add-audio:
    sudo usermod -a -G realtime $(whoami)

# TODO: shortcuts for common realtime/audio benchmarks

# TODO: shortcut to disable wifi & bluetooth

# Shortcut for manually editing kernel arguments
[group('kernel')]
edit-kargs:
    sudo rpm-ostree kargs --editor

# TODO: CPU isolation kernel settings

# TODO: apply mitigations=off with a scary warning message

# TODO: apply usbcore.quirks=<vendor:product>:u for giving usb interfaces special priority,
#       use something like 'lsusb | gum choose' for device selection

# TODO: shortcut for searching for and layering packages from ycollet/audinux COPR
