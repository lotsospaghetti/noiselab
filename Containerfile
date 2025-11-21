ARG ARCH="${ARCH:-x86_64}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/base-main}"
ARG BASE_NAME="${BASE_NAME}:${FEDORA_VERSION}"

ARG KERNEL_IMAGE="${KERNEL_IMAGE:-ghcr.io/bazzite-org/kernel-bazzite}"
ARG KERNEL_NAME="${KERNEL_IMAGE}:latest-f${FEDORA_VERSION}-${ARCH}"
FROM ${KERNEL_NAME} AS kernel

ARG BUILD_NVIDIA="${BUILD_NVIDIA:-no}"
ARG NVIDIA_IMAGE="${NVIDIA_IMAGE:-ghcr.io/bazzite-org/nvidia-drivers}"
ARG NVIDIA_NAME="${NVIDIA_IMAGE}:latest-f${FEDORA_VERSION}-${ARCH}"
FROM ${NVIDIA_NAME} AS nvidia

##############
# BASE BUILD
##############

FROM ${BASE_NAME} AS noiselab

COPY system_files/base /
COPY build_files /ctx/

# install Bazzite kernel
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=kernel,src=/,dst=/tmp/rpms/kernel \
    /ctx/install-bazzite-kernel && \
    /ctx/cleanup

# copy Bazzite's install-firmware script from upstream and run it
ADD https://raw.githubusercontent.com/ublue-os/bazzite/refs/heads/main/build_files/install-firmware /ctx/install-firmware
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/install-firmware && \
    /ctx/cleanup

# build initramfs and finalize
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/initramfs && \
    /ctx/post-install && \
    rm -rf /ctx

RUN bootc container lint
