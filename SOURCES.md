Tuning a Linux system for low-latency audio can be a very deep rabbithole to get into, and I'm by no means an expert so a lot of the configuration, scripts, and installed software in this image is informed by manuals and online guides from people who *probably* know more of what they're talking about. I'll try to keep this page updated with any sources I've taken specific things from along with my rationale for adding said things.

- Fedora-specific configuration: [Fedora Pipewire Low Latency Audio Configuration Reference Guide v.1.02](https://linuxmusicians.com/viewtopic.php?p=182438#p182438)

Anything having to do with Fedora specifically was likely taken from Audiojunkie's guide here. Note that there's a [2.0 version of this guide](https://linuxmusicians.com/viewtopic.php?t=27121) in the works that has a whole section for Fedora Atomic images!

- Default kernel arguments: [Linux as a Pro Audio Workstation in 2025: The Complete, No-Nonsense Guide](https://gearspace.com/board/showpost.php?p=17633244&postcount=2&s=0bd38421a90c200c2fec9da6604fec93)

The kargs used here mostly seem like they'd make for sane defaults and it's quite comprehensive, only missing the `preempt=full` karg because that guide assumes you're using a custom realtime kernel.
