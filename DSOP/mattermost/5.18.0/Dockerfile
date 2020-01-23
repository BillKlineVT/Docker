################################################################################
# Default Registry Var
ARG BASE_REGISTRY=registry.access.redhat.com
ARG BASE_IMAGE=ubi7/ubi
ARG BASE_TAG=7.7

################################################################################
# DSOP Pipeline Compliant Registry FROM String
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}
USER 0

#################################################################################
# Mattermost Package Variables
ARG PKG_VERS="5.18.0"
ARG PKG="mattermost"
ARG VENDOR="mattermost"
ARG EDITION="team"

#################################################################################
# Build File Names
ARG PKG_NAME="${PKG}-${EDITION}"
ARG PKG_NAME_LONG="${PKG_NAME}-${PKG_VERS}-linux-amd64"
ARG PKG_TAR="${PKG_NAME_LONG}.tar.gz"
ARG PKG_SHA="${PKG_TAR}.sha"
ARG BUNDLE="${PKG_NAME}-bundle.tar.gz"

# App & Staging Paths
ARG APP_DIR="/mattermost"
ENV APP_DIR="${APP_DIR}"
ARG STAGING_DIR="/tmp/${PKG_NAME}-build"
ARG PKG_TAR_PATH="${STAGING_DIR}/${PKG_TAR}"
ARG BUNDLE_TAR_PATH="${STAGING_DIR}/${BUNDLE}"

#################################################################################
# Artifact Repo Target & Auth Variables

# Nexus Server
ENV NEXUS_SERVER="${NEXUS_SERVER}/dsop"
# LOCAL TESTING:
#ENV NEXUS_SERVER="https://nexus-secure.levelup-dev.io/repository/dsop"

# Artifact Path
ARG ARTIFACT_PATH="${VENDOR}/${PKG_VERS}"

# Artifact Repo Target URLs:
ARG NEXUS_BUNDLE_URL="${NEXUS_SERVER}/${ARTIFACT_PATH}/${BUNDLE}"
ARG NEXUS_BUNDLE_SHA_URL="${NEXUS_SERVER}/${BUNDLE}.sha"

################################################################################
# Container Metadata

LABEL name="Mattermost-${EDITION}-edition" \
      maintainer="carlos@mattermost.com"     \
      vendor="Mattermost"                    \
      release="${VERSION}"                   \
      summary="Install Mattermost ${EDITION} Edition" \
      description="Mattermost is an open source, hybrid messaging workspace that\
      brings together your conversations and tools to get more done, faster."

################################################################################
# Yum build dependencies & Flags
ARG YUM_LIST="ca-certificates curl libc6-compat libffi-dev linux-headers \
              mailcap netcat-openbsd xmlsec-dev tzdata" 

ARG YUM_FLAGS="\
                -y --nogpgcheck \
                --disablerepo=unified_platform_ubi8_appstream \
                --disablerepo=unified_platform_ubi8_os \
                --disableplugin=subscription-manager \
                "

# LOCAL TESTING
#ARG YUM_FLAGS="\
#                -y --nogpgcheck \
#                --disableplugin=subscription-manager \
#                "

################################################################################
# Yum Install Packages
RUN set -x \
    && yum update  ${YUM_FLAGS} 
RUN set -x \
    && yum install ${YUM_FLAGS} ${YUM_LIST} 

################################################################################
# Fetch Mattermost Bundle from Artifact Repo
RUN set -x \
    && mkdir -p ${STAGING_DIR}             \
                ${APP_DIR}/bak             \
                ${APP_DIR}/data            \
                ${APP_DIR}/logs            \
                ${APP_DIR}/config          \
                ${APP_DIR}/plugins         \
                ${APP_DIR}/client/plugins  \
                /licenses                   

RUN set -x \
    && cd ${STAGING_DIR}                   \
    && curl --create-dirs                  \
            -fksSL ${NEXUS_BUNDLE_URL}     \
            -o     ${BUNDLE_TAR_PATH}      \
    && tar  -zxf   ${BUNDLE_TAR_PATH}      \
            -C     ${STAGING_DIR}/         \
    && tar  -zxf   ${PKG_TAR_PATH}         \
            -C     ${APP_DIR}/

################################################################################
# Get ready for production
ARG PUID=2000
ARG PGID=2000

RUN set -ex \
    && groupadd -g ${PGID} mattermost     \
    && useradd  -u ${PUID}                \
                -g mattermost             \
                -d /mattermost mattermost \
    && chown -R mattermost:mattermost ${APP_DIR}

################################################################################
# Cleanup
RUN set -x \
    && rm -rf ${STAGING_DIR}

################################################################################
# Healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
        CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1

################################################################################
# PATH
ENV PATH="/mattermost/bin:${PATH}"

# USER Settings
USER mattermost

################################################################################
# Final Configs

# entrypoint and command
COPY scripts/entrypoint.sh /
WORKDIR ${APP_DIR}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mattermost"]

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]

# Configure exposed ports
EXPOSE 80
EXPOSE 443
EXPOSE 8065 
EXPOSE 8067 
EXPOSE 8074 
EXPOSE 8075
