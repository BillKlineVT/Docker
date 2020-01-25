ARG BASE_REGISTRY=registry.access.redhat.com
ARG BASE_IMAGE=ubi7/ubi
ARG BASE_TAG=7.8

# This builder image was pushed to Nexus using prebuild.sh and will be used to copy binaries from
FROM nexus-docker.52.61.140.4.nip.io/builder-opensource/keycloak:6.0.1 AS builder

# This is the base image
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

LABEL name="Keycloak" \
      description="Keycloak is an open source Identity and Access Management solution aimed at modern applications and services. It makes it easy to secure applications and services with little to no code." \
      vendor="Opensource" \
      summary="Keycloak (Red Hat UBI)" \
      maintainer="Red Hat <hojeda@redhat.com>" \
      version="6.0.1"

ENV KEYCLOAK_VERSION=6.0.1 \
    JDBC_POSTGRES_VERSION=42.2.5 \
    JDBC_MYSQL_VERSION=5.1.46 \
    JDBC_MARIADB_VERSION=2.2.3 \
    LAUNCH_JBOSS_IN_BACKGROUND=1 \
    PROXY_ADDRESS_FORWARDING=false \
    JBOSS_HOME=/opt/jboss/keycloak \
    LANG=en_US.UTF-8 \
    KEYCLOAK_USER_NAME=jboss \
    KEYCLOAK_USER_ID=1001 \
    KEYCLOAK_HOME=/opt/jboss

ARG GIT_REPO
ARG GIT_BRANCH
ARG KEYCLOAK_DIST=https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

# Copy binaries from builder image
COPY --from=builder /opt/jboss /opt/jboss

# Create the user, fix file system ownership
RUN useradd -M -s /usr/sbin/nologin --uid ${KEYCLOAK_USER_ID} --user-group ${KEYCLOAK_USER_NAME} && \
    chown -R ${KEYCLOAK_USER_NAME}:${KEYCLOAK_USER_NAME} ${KEYCLOAK_HOME} && \
    chmod -R o-w /opt/jboss/keycloak

# Install dependencies
RUN yum install -y --disableplugin=subsciption-manager \
                   --nogpgcheck \
                   --disablerepo=unified_platform_ubi8_appstream \
                   --disablerepo=unified_platform_ubi8_os \
                   java-1.8.0-openjdk && \
    yum clean all

USER ${KEYCLOAK_USER_ID}

EXPOSE 8080

HEALTHCHECK --timeout=5m --start-period=2m --retries=3 CMD curl http://localhost/auth || exit 1

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]
