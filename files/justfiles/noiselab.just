# Apply the necessary groups to the current user
add_audio:
    sudo usermod -a -G realtime,pipewire $(whoami)

# TODO: CPU isolation kernel settings
