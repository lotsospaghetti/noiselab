# Shortcut for paging through packages installed or layered in booted image
[group('development')]
list-installed-packages:
    dnf list --installed | less
