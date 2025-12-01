# noiselab

A low-latency audio workstation OS based on [Universal Blue's base image](https://github.com/ublue-os/main) focused on music production, an easy-to-grasp introduction to JACK-centric workflows, and compatibility with Windows-only music gear and software.

This project is just starting out so I wouldn't advise trying to use it for anything beyond testing purposes.

## Features (so far)

- Prioritizes packages from the [Audinux repository](https://audinux.github.io/), a COPR which features tons of audio software built for Fedora.
- Optimizations for [Liquorix](https://liquorix.net/) and/or [XanMod](https://xanmod.org/), stock, or [Bazzite](https://github.com/bazzite-org/kernel-bazzite) Linux kernels that *(should)* come mostly out-of-the-box. *(more on planned image types in the next section)*
- Several [distrobox-assemble files](/system_files/base/etc/distrobox) that enable a containerized approach to installing and maintaining additional music software. For instance, installing VCV Rack and all its available plugins would be as simple as typing `distrobox assemble create --file /etc/distrobox/vcv-rack.ini`, and removing everything VCV Rack-related is just as easily done with `distrobox assemble rm --file /etc/distrobox/vcv-rack.ini`!
- Flatpak, [webapp-manager](https://copr.fedorainfracloud.org/coprs/bazzite-org/webapp-manager/), and [QEMU](https://www.qemu.org/) also included for making more audio software accessible in some form.

## Planned images

This is something that's been nagging at me for a while, since the biggest hurdle for me has been trying to conceptualize what image options I should offer to the end-user. I'd *like* to offer two distinct `base` and `desktop` images; the latter featuring a standard fully-featured interface and the former being a trimmed-down option to fit niche applications or be the base of someone else's cloud-native project. But factoring in all the aforementioned kernels, NVIDIA drivers, and possible ARM support could lead to a dense image list that'd overwhelm people who likely just want to make some damn music.

So, this is the image list I'm gonna try offering:

- `desktop`: The default experience meant for non-NVIDIA x86_64 desktops. Would feature the Liquorix and stock kernels that can be chosen at boot-time.
- `desktop-nvidia`: The NVIDIA desktop image, with the XanMod\* and stock kernels.
- `desktop-arm`: No idea how well ARM is supported by Universal Blue but if it's at all possible, this would be the desktop image for it.
- `base`, `base-nvidia`, and `base-arm`: Minimal images specifically for building something out of, same hardware/kernel support as their desktop counterparts.
- `bazzite`, `bazzite-nvidia`, and `bazzite-base`: Bazzite kernel-only builds intended for hardware specifically supported by it, such as handheld gaming PCs.

\*Anecdotally I installed the Fedora COSMIC spin to an NVIDIA desktop and threw both Liquorix and XanMod on it, and only the latter boots successfully. That's my only justification for XanMod here atm

## Special thanks

As excited as I am about making this a real OS that might help people give Linux audio production a try, the reality is I'm just putting together work done by folks who know a *lot* more about what they're doing! I'm simply learning as I go here, both with Linux audio production and cloud-native container technologies. With that said, here's a shout-out to some projects, people, and resources that make something like this possible:

- [Bazzite](https://bazzite.gg/) which impressed me so much with how much it makes PC gaming Just Work™️ that it inspired me to take a crack at making something like it for music production. Also worth mentioning [Universal Blue](https://universal-blue.org/) which is the parent project of Bazzite and what noiselab is directly based on.
- [ycollet](https://discussion.fedoraproject.org/u/ycollet/summary), who appears to be the primary maintainer of the Audinux repository. Huge thanks for providing a vast repository like that!
- [Audiojunkie](https://linuxmusicians.com/memberlist.php?mode=viewprofile&u=15946) on the LinuxMusicians forum, who seems to have done a ton of their own research on optimizing Fedora for audio production and has posted detailed guides such as [this](https://linuxmusicians.com/memberlist.php?mode=viewprofile&u=15946) and [this](https://linuxmusicians.com/viewtopic.php?t=27398) that really helped me conceptualize a bunch of things.
- [ArchWiki](https://wiki.archlinux.org/title/Main_page).

## Project goals (messy notes I wrote when I created this repo)

The overall goal is to create a pro audio setup within a [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) image to fill that niche within the [cloud native](https://universal-blue.org/#cloud-native) desktop space. My personal motivation for starting this project is to move away from Windows for music production, and although there's [plenty of good audio distributions out there](https://wiki.linuxaudio.org/apps/categories/distributions) I have a lot of my own ideas, as you can probably tell by the list below... 😅

- [x] Build on top of the cloud-native and atomic framework provided by `ublue-os/base-main` for more reliability and, frankly, less maintenance
- [x] Also build off of existing [audio distributions](https://wiki.linuxaudio.org/apps/categories/distributions) such as [Fedora Jam](https://fedoraproject.org/labs/jam)
- [x] ~~Use a realtime kernel such as the [Liquorix Kernel](https://liquorix.net/) or [kernel-cachyos-rt](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/)~~
  - ~~After some exhaustive research on what makes sense for pro audio use (and also general research, kernels aren't something I have much experience with yet), I'm going to use the generic [Bazzite kernel](https://github.com/bazzite-org/kernel-bazzite) with `preempt=full nohz_full=all threadirqs` kargs for extended hardware support. Perhaps as a stretch goal I'll try compiling a realtime kernel from Bazzite's patches and offering that as a separate image.~~
  - Actually I literally just realized there's several realtime kernels in [ycollet/audinux](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/), that's much appreciated!
- [x] Apply at least some [system optimizations](https://wiki.linuxaudio.org/wiki/system_configuration) and provide [ujust scripts](https://docs.bazzite.gg/Installing_and_Managing_Software/ujust/#project-website) to make system-specific optimizations easier
- [x] Provide libvirt/KVM/QEMU as a way to use Windows-only software and hardware. Also install [Bottles](https://usebottles.com/) and [yabridge](https://github.com/robbert-vdh/yabridge) by default as a lighter option
- [x] Provide useful configuration software such as [Cadence](https://kx.studio/Applications:Cadence) and [rtcqs](https://codeberg.org/rtcqs/rtcqs) out-of-the-box
- [x] Utilize [distrobox](https://distrobox.it/) containers to provide optional audio packages
- [ ] Provide `ujust` scripts to help install closed-source and/or paid software such as [Renoise](https://www.renoise.com/)
- [ ] ~~Not sure what DE/WM I want to go with, but it should ideally be lighter than GNOME and KDE~~ Honestly likely gonna go with COSMIC
- [ ] Provide a custom curated tab for [Bazaar](https://github.com/kolunmi/bazaar) highlighting audio-related Flatpaks
- [ ] Make a wiki of some kind with helpful information for setting things up
- [x] Include [webapp-manager](https://copr.fedorainfracloud.org/coprs/bazzite-org/webapp-manager/) for web audio applications such as [strudel](https://strudel.cc/)
- [x] Use something like [cage](https://github.com/cage-kiosk/cage) to define a DAW or DJ software to exclusively open within its own session. Possibly useful for live performances
- [ ] Try supporting ARM platforms like Raspberry Pi
- [ ] Make a build that, like, actually passes...
