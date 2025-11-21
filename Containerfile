ARG ARCH="${ARCH:-x86_64}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/base-main}"
ARG BASE_NAME="${BASE_IMAGE}:${FEDORA_VERSION}"

ARG KERNEL_IMAGE="${KERNEL_IMAGE:-ghcr.io/bazzite-org/kernel-bazzite}"
ARG KERNEL_NAME="${KERNEL_IMAGE}:latest-f${FEDORA_VERSION}-${ARCH}"
FROM ${KERNEL_NAME} AS kernel

#ARG NVIDIA_IMAGE="${NVIDIA_IMAGE:-ghcr.io/bazzite-org/nvidia-drivers}"
#ARG NVIDIA_NAME="${NVIDIA_IMAGE}:latest-f${FEDORA_VERSION}-${ARCH}"
#FROM ${NVIDIA_NAME} AS nvidia

##############
# BASE BUILD
##############

FROM ${BASE_NAME} AS noiselab

ARG IMAGE_NAME="${IMAGE_NAME:-noiselab}"

COPY system_files/base /
COPY ./build_files/install-bazzite-kernel ./build_files/cleanup /ctx/

# setup Copr repos
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    dnf5 -y copr enable bazzite-org/bazzite && \
    dnf5 -y copr enable bazzite-org/bazzite-multilib && \
    dnf5 -y copr enable ublue-os/staging && \
    dnf5 -y copr enable ublue-os/packages && \
    /ctx/cleanup

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
    chmod +x /ctx/install-firmware && \
    /ctx/install-firmware && \
    /ctx/cleanup

# disable Copr repos
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    dnf5 -y copr disable bazzite-org/bazzite && \
    dnf5 -y copr disable bazzite-org/bazzite-multilib	&& \
    dnf5 -y copr disable ublue-os/staging && \
    dnf5 -y copr disable ublue-os/packages && \
    /ctx/cleanup

COPY ./build_files/initramfs ./build_files/post-install /ctx/

# build initramfs and finalize
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /ctx/initramfs && \
    /ctx/post-install && \
    rm -rf /ctx

RUN bootc container lint
