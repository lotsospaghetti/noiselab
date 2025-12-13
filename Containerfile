ARG ARCH="${ARCH:-x86_64}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/base-main}"
ARG BASE_NAME="${BASE_IMAGE}:${FEDORA_VERSION}"

ARG BAZZITE_KERNEL_IMG="${BAZZITE_KERNEL_IMG:-ghcr.io/bazzite-org/kernel-bazzite:latest-f${FEDORA_VERSION}-${ARCH}}"
#FROM ${BAZZITE_KERNEL_IMG} as bazzite-kernel

################
# DESKTOP BUILD
################

FROM ${BASE_NAME} AS noiselab

ARG ARCH="${ARCH:-x86_64}"
ARG IMAGE_NAME="${IMAGE_NAME:-base}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-lqx}"
ARG NVIDIA_VERSION="${NVIDIA_VERSION:-none}"

COPY ./build_files/setup-coprs ./build_files/setup-repos ./build_files/cleanup /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    mkdir -p /var/roothome && \
    /ctx/setup-coprs enable && \
    /ctx/setup-repos enable && \
    /ctx/cleanup

#    --mount=type=bind,from=bazzite-kernel,src=/,dst=/tmp/bazzite-kernel \
COPY ./build_files/install-kernel /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-kernel && \
    /ctx/cleanup

# TODO: firmware install

COPY ./build_files/install-libvirt /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-libvirt && \
    /ctx/cleanup

COPY ./build_files/configure-realtime /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/configure-realtime && \
    /ctx/cleanup

COPY ./build_files/install-yabridge /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-yabridge && \
    /ctx/cleanup

COPY ./build_files/configure-system /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/configure-system && \
    /ctx/cleanup

COPY ./build_files/install-desktop /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-desktop && \
    /ctx/cleanup

# finalize base image
COPY ./system_files/base-${ARCH}/usr ./system_files/base-${ARCH}/etc /
COPY ./build_files/initramfs ./build_files/post-install /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/initramfs && \
    /ctx/setup-repos disable && \
    /ctx/setup-coprs disable && \
    /ctx/post-install && \
    rm -rf /ctx

RUN bootc container lint
