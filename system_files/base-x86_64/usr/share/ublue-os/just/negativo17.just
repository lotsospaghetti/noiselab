# vim: set ft=make :

# Fetch MakeMKV registration code and copy it to clipboard (https://forum.makemkv.com/forum/viewtopic.php?f=5&t=1053)
[group("multimedia")]
makemkv-registration-code:
    #!/usr/bin/bash
    error_msg() {
        printf '%s\n' \
            'Something went wrong, check your internet connection.' \
            'Alternatively, you can go to the forum post in a browser to get the code there:' \
            'https://forum.makemkv.com/forum/viewtopic.php?f=5&t=1053' \
        exit 1
    }
    trap 'error_msg' ERR
    curl -s 'https://forum.makemkv.com/forum/viewtopic.php?f=5&t=1053' | \
        grep -o '<code>.*</code>' | \
        sed -E 's|</?code>||g' | \
        wl-copy
