# noiselab &nbsp; [![bluebuild build badge](https://github.com/blue-build/template/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/template/actions/workflows/build.yml)

> [!WARNING]
> This image IS NOT intended for general desktop or networked use! It prioritizes realtime audio handling almost entirely above anything else, **including security!** Use it at your own risk, preferrably on decdicated hardware isolated from your primary network/infrastructure.

A WIP Fedora bootc project to make a Linux pro audio image geared towards low-powered devices and streamlined setup. This is a follow-up to a [similar project](https://github.com/lotsospaghetti/noiselab-archive) I tried to make a while back, but this time around my only real goal is to turn a Microsoft Surface into a makeshift VST effects box that's reliable enough for live performance use. I figure an image-based Linux is the right tool for this application so... yeah.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/lotsospaghetti/noiselab:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/lotsospaghetti/noiselab:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/lotsospaghetti/noiselab
```
