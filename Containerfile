ARG ARCH="${ARCH:-x86_64}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/base-main}"
ARG BASE_NAME="${BASE_IMAGE}:${FEDORA_VERSION}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-lqx}"
ARG BAZZITE_KERNEL_IMG="${BAZZITE_KERNEL_IMG:-ghcr.io/bazzite-org/kernel-bazzite:latest-f${FEDORA_VERSION}-${ARCH}}"
ARG NVIDIA_VERSION="${NVIDIA_VERSION:-none}"

ARG DESKTOP_BASE="${DESKTOP_BASE:-base}"
FROM ${BAZZITE_KERNEL_IMG} as bazzite-kernel

###############
# BASE BUILD
###############

FROM ${BASE_NAME} AS base

ARG IMAGE_NAME="${IMAGE_NAME:-base}"

COPY ./build_files/setup-coprs ./build_files/setup-repos ./build_files/cleanup /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    mkdir -p /var/roothome && \
    /ctx/setup-coprs enable && \
    /ctx/setup-repos enable && \
    /ctx/cleanup

COPY ./build_files/install-kernel /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=bazzite-kernel,src=/,dst=/tmp/bazzite-kernel \
    /ctx/install-kernel && \
    /ctx/cleanup

COPY ./packages/base-${ARCH}.packages /tmp/packagelist
COPY ./build_files/install-packagelist /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-packagelist && \
    /ctx/cleanup

COPY ./build_files/configure-system /ctx/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/configure-system && \
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

###############
# DESKTOP BUILD
###############

#from ${DESKTOP_BASE} as desktop

#COPY ./build_files/setup-coprs ./build_files/setup-repos ./build_files/cleanup /ctx/
#RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    mkdir -p /var/roothome && \
    /ctx/setup-coprs enable && \
    /ctx/setup-repos enable && \
    /ctx/cleanup

#COPY ./packages/desktop-${ARCH}.packages /tmp/packagelist
#COPY ./build_files/install-packagelist /ctx/
#RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-packagelist && \
    /ctx/cleanup

# finalize desktop image
#COPY ./system_files/desktop-${ARCH}/usr ./system_files/desktop-${ARCH}/etc /
#COPY ./build_files/initramfs ./build_files/post-install /ctx/
#RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/initramfs && \
    /ctx/setup-repos disable && \
    /ctx/setup-coprs disable && \
    /ctx/post-install && \
    rm -rf /ctx

#RUN bootc container lint
