ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/base-main}"

FROM ${BASE_IMAGE}:${FEDORA_VERSION} AS noiselab

ARG ARCH="${ARCH:-x86_64}"
ARG IMAGE_NAME="${IMAGE_NAME:-noiselab}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-lqx}"
ARG NVIDIA_VERSION="${NVIDIA_VERSION:-none}"

# install Homebrew
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /

COPY ./build_files/01-setup-repos ./build_files/99-cleanup /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/01-setup-repos enable && \
    /ctx/99-cleanup

COPY ./build_files/02-install-kernel /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/02-install-kernel && \
    /ctx/99-cleanup

# TODO: firmware install

COPY ./build_files/04-install-libvirt /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/04-install-libvirt && \
    /ctx/99-cleanup

COPY ./build_files/05-configure-realtime /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/05-configure-realtime && \
    /ctx/99-cleanup

COPY ./build_files/06-install-wine-tkg/ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/06-install-wine-tkg && \
    /ctx/99-cleanup

COPY ./build_files/07-configure-system /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/07-configure-system && \
    /ctx/99-cleanup

COPY ./build_files/08-install-desktop /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/08-install-desktop && \
    /ctx/99-cleanup

COPY ./build_files/09-install-audinux/ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/09-install-audinux && \
    /ctx/99-cleanup

# finalize base image
COPY ./system_files/base-${ARCH}/usr ./system_files/base-${ARCH}/etc /
COPY ./build_files/97-initramfs ./build_files/98-post-install /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/97-initramfs && \
    /ctx/01-setup-repos disable && \
    /ctx/98-post-install && \
    rm -rf /ctx

RUN bootc container lint
