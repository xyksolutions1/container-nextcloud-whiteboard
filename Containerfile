# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Nextcloud Whiteboard Collaboration Server" \
        org.opencontainers.image.description="Nextcloud Whiteboard Collaboration Server" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/nextcloud-whiteboard" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-nextcloud-whiteboard/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-nextcloud-whiteboard.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    NCWBCS_VERSION="v1.5.7" \
    NCWBCS_REPO_URL="https://github.com/nextcloud/whiteboard"


COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    IMAGE_NAME="nfrastack/nextcloud-whiteboard" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-nextcloud-whiteboard/"

RUN echo "" && \
    NCWBCS_BUILD_DEPS_ALPINE=" \
                                git \
                             " \
                            && \
    NCWBCS_RUN_DEPS_ALPINE=" \
                                nodejs \
                                npm \
                           " \
                           && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user ncwbcs 1000 ncwbcs 1000 /dev/null && \
    package update && \
    package upgrade && \
    package install \
                        NCWBCS_BUILD_DEPS \
                        NCWBCS_RUN_DEPS \
                        && \
    \
    clone_git_repo "${NCWBCS_REPO_URL}" "${NCWBCS_VERSION}" /app && \
    npm install --global clean-modules && \
    npm install && \
    npm run build && \
    rm -rf .git && \
    container_build_log add "Nextcloud Whiteboard" "${NCWBCS_VERSION}" "${NCWBCS_REPO_URL}" && \
    package remove \
                    NCWBCS_BUILD_DEPS \
                    && \
    package cleanup

COPY rootfs /
