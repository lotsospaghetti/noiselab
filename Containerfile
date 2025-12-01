ARG ARCH="${ARCH:-x86_64}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/base-main}"
ARG BASE_NAME="${BASE_IMAGE}:${FEDORA_VERSION}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-lqx}"
ARG NVIDIA_VERSION="${KERNEL_FLAVOR:-none}"

ARG DESKTOP_BASE="${DESKTOP_BASE:-noiselab}"

###############
# BASE BUILD
###############

FROM ${BASE_NAME} AS noiselab

ARG IMAGE_NAME="${IMAGE_NAME:-noiselab-base}"

COPY ./build_files/setup-coprs ./build_files/setup-repos ./build_files/install-kernel ./build_files/cleanup ./build_files/configure-system ./build_files/install-packagelist /ctx/

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/setup-coprs enable && \
    /ctx/setup-repos enable && \
    /ctx/cleanup

COPY --from=ghcr.io/bazzite-org/kernel-bazzite:latest-f${FEDORA_VERSION}-${ARCH} / /tmp/bazzite-kernel

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-kernel && \
    /ctx/cleanup

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/configure-system && \
    /ctx/cleanup

COPY ./packages/base.packages /tmp/packagelist

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-packagelist && \
    /ctx/cleanup

COPY ./build_files/initramfs ./build_files/post-install /ctx/
COPY ./system_files/base/usr ./system_files/base/etc /

# finalize image
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

from $DESKTOP_BASE as noiselab-desktop

RUN bootc container lint
