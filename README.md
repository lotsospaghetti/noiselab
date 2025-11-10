# noiselab

A low-latency audio workstation OS based on [Universal Blue's base image](https://github.com/ublue-os/main) focused on audio production, including compatibility with music gear and software that only plays nice with Windows.

# Project goals

- [ ] Build on top of the cloud-native and immutable framework provided by `ublue-os/base-main` for more reliability and, frankly, less maintenance
- [ ] Also build off of existing [audio distributions](https://wiki.linuxaudio.org/apps/categories/distributions) such as [Fedora Jam](https://fedoraproject.org/labs/jam)
- [ ] Use a realtime kernel such as the [Liquorix Kernel](https://liquorix.net/) or [kernel-cachyos-rt](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/)
- [ ] Apply at least some [system optimizations](https://wiki.linuxaudio.org/wiki/system_configuration) and provide [ujust scripts](https://docs.bazzite.gg/Installing_and_Managing_Software/ujust/#project-website) to make system-specific optimizations easier
- [ ] Provide libvirt/KVM/QEMU as a way to use Windows-only software and hardware. Also install [Bottles](https://usebottles.com/) and [yabridge](https://github.com/robbert-vdh/yabridge) by default as a lighter option
- [ ] Provide useful configuration software such as [Cadence](https://kx.studio/Applications:Cadence) and [rtcqs](https://codeberg.org/rtcqs/rtcqs) out-of-the-box
- [ ] Utilize [distrobox](https://distrobox.it/) containers to provide optional audio packages
- [ ] Provide `ujust` scripts to help install closed-source and/or paid software such as [Renoise](https://www.renoise.com/)
- [ ] Not sure what DE/WM I want to go with, but it should ideally be lighter than GNOME and KDE
- [ ] Provide a custom curated tab for [Bazaar](https://github.com/kolunmi/bazaar) highlighting audio-related Flatpaks
