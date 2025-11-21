# noiselab

A low-latency audio workstation OS based on [Universal Blue's base image](https://github.com/ublue-os/main) focused on audio production, including compatibility with music gear and software that only plays nice with Windows.

# Project goals

The overall goal is to create a pro audio setup within a [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) image to fill that niche within the [cloud native](https://universal-blue.org/#cloud-native) desktop space. My personal motivation for starting this project is to move away from Windows for music production, and although there's [plenty of good audio distributions out there](https://wiki.linuxaudio.org/apps/categories/distributions) I have a lot of my own ideas, as you can probably tell by the list below... 😅

- [ ] Build on top of the cloud-native and atomic framework provided by `ublue-os/base-main` for more reliability and, frankly, less maintenance
- [ ] Also build off of existing [audio distributions](https://wiki.linuxaudio.org/apps/categories/distributions) such as [Fedora Jam](https://fedoraproject.org/labs/jam)
- [ ] ~~Use a realtime kernel such as the [Liquorix Kernel](https://liquorix.net/) or [kernel-cachyos-rt](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/)~~
  - After some exhaustive research on what makes sense for pro audio use (and also general research, kernels aren't something I have much experience with yet), I'm going to use the generic [Bazzite kernel](https://github.com/bazzite-org/kernel-bazzite) with `preempt=full nohz_full=all threadirqs` kargs for extended hardware support. Perhaps as a stretch goal I'll try compiling a realtime kernel from Bazzite's patches and offering that as a separate image.
- [ ] Apply at least some [system optimizations](https://wiki.linuxaudio.org/wiki/system_configuration) and provide [ujust scripts](https://docs.bazzite.gg/Installing_and_Managing_Software/ujust/#project-website) to make system-specific optimizations easier
- [ ] Provide libvirt/KVM/QEMU as a way to use Windows-only software and hardware. Also install [Bottles](https://usebottles.com/) and [yabridge](https://github.com/robbert-vdh/yabridge) by default as a lighter option
- [ ] Provide useful configuration software such as [Cadence](https://kx.studio/Applications:Cadence) and [rtcqs](https://codeberg.org/rtcqs/rtcqs) out-of-the-box
- [ ] Utilize [distrobox](https://distrobox.it/) containers to provide optional audio packages
- [ ] Provide `ujust` scripts to help install closed-source and/or paid software such as [Renoise](https://www.renoise.com/)
- [ ] Not sure what DE/WM I want to go with, but it should ideally be lighter than GNOME and KDE
- [ ] Provide a custom curated tab for [Bazaar](https://github.com/kolunmi/bazaar) highlighting audio-related Flatpaks
- [ ] Make a wiki of some kind with helpful information for setting things up
- [ ] Include [webapp-manager](https://copr.fedorainfracloud.org/coprs/bazzite-org/webapp-manager/) for web audio applications such as [strudel](https://strudel.cc/)
- [ ] Use something like [cage](https://github.com/cage-kiosk/cage) to define a DAW or DJ software to exclusively open within its own session. Possibly useful for live performances
