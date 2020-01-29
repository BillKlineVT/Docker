# Copyright (c) 2016-present Sonatype, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
ARG BASE_REGISTRY=registry.access.redhat.com
ARG BASE_IMAGE=ubi7/ubi
ARG BASE_TAG=latest
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

MAINTAINER "maintainer@dsop.io"

LABEL name="Nexus Repository Manager" \
      vendor=Sonatype \
      maintainer="Sonatype <cloud-ops@sonatype.com>" \
      version="3.16.2-01" \
      release="3.16.2" \
      url="https://sonatype.com" \
      summary="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      description="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      run="docker run -d --name NAME \
          -p 8081:8081 \
          IMAGE" \
      stop="docker stop NAME" \
      com.sonatype.license="Apache License, Version 2.0" \
      com.sonatype.name="Nexus Repository Manager base image" \
      io.k8s.description="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      io.k8s.display-name="Nexus Repository Manager" \
      io.openshift.expose-services="8081:8081" \
      io.openshift.tags="Sonatype,Nexus,Repository Manager"

ARG NEXUS_VERSION=3.16.2-01
ARG NEXUS_SERVER=nexus.52.61.140.4.nip.io
# configure nexus runtime
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
    NEXUS_DATA=/nexus-data \
    NEXUS_CONTEXT='' \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work \
    USER_NAME=nexus \
    USER_UID=200

RUN echo "SERVER= ${NEXUS_SERVER}" 
COPY scripts/uid_entrypoint /
RUN curl -Lk https://${NEXUS_SERVER}/repository/cht/nexus/nexus-${NEXUS_VERSION}-unix.tar --output \tmp\nexus-${NEXUS_VERSION}-unix.tar


# Install JDK
RUN yum update -y --nogpgcheck --disableplugin=subscription-manager && \
yum -y install --disableplugin=subscription-manager --nogpgcheck java-1.8.0-openjdk && \
yum clean all
    

# Install NexusRM
# Install Nexus and Configure Nexus Runtime Environment
RUN mkdir -p ${NEXUS_HOME} 
RUN tar -x -C ${NEXUS_HOME} --strip-components=1 nexus-${NEXUS_VERSION} -f \tmp\nexus-${NEXUS_VERSION}-unix.tar  
RUN chown -R root:root ${NEXUS_HOME} 
RUN sed -e "/^nexus-context/ s:$:${NEXUS_CONTEXT}:" -i ${NEXUS_HOME}/etc/nexus-default.properties
RUN useradd -l -u ${USER_UID} -r -g 0 -m -d ${NEXUS_DATA} -s /sbin/no-login \
            -c "${USER_NAME} application user" ${USER_NAME} 
RUN mkdir -p ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK} 
RUN ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 
RUN chown -R ${USER_NAME}:0 ${NEXUS_DATA} 
RUN chmod -R g+rw ${NEXUS_DATA} /etc/passwd 
RUN chmod ug+x /uid_entrypoint 
RUN find ${NEXUS_DATA} -type d -exec chmod g+x {} +

# Install keycloak plugin from https://github.com/flytreeleft/nexus3-keycloak-plugin

ENV NEXUS_PLUGINS ${NEXUS_HOME}/system

# https://github.com/flytreeleft/nexus3-keycloak-plugin
ENV KEYCLOAK_PLUGIN_VERSION 0.3.4
ENV KEYCLOAK_PLUGIN_RELEASE 0.3.4
ENV KEYCLOAK_PLUGIN /org/github/flytreeleft/nexus3-keycloak-plugin/${KEYCLOAK_PLUGIN_RELEASE}/nexus3-keycloak-plugin-${KEYCLOAK_PLUGIN_VERSION}

USER root

ADD https://github.com/flytreeleft/nexus3-keycloak-plugin/releases/download/v${KEYCLOAK_PLUGIN_RELEASE}/nexus3-keycloak-plugin-${KEYCLOAK_PLUGIN_VERSION}.jar \
     ${NEXUS_PLUGINS}${KEYCLOAK_PLUGIN}.jar

RUN chmod 644 ${NEXUS_PLUGINS}/org/github/flytreeleft/nexus3-keycloak-plugin/${KEYCLOAK_PLUGIN_RELEASE}/nexus3-keycloak-plugin-${KEYCLOAK_PLUGIN_VERSION}.jar
RUN echo "reference\:file\:${KEYCLOAK_PLUGIN}.jar = 200" >> ${NEXUS_HOME}/etc/karaf/startup.properties

VOLUME ${NEXUS_DATA}

# arbitrary uid recognition at runtime - for OpenShift deployments
RUN sed "s@${USER_NAME}:x:${USER_UID}:@${USER_NAME}:x:\${USER_ID}:@g" /etc/passwd > /etc/passwd.template

# Supply non variable to USER command ${USER_NAME}
USER 200
WORKDIR ${NEXUS_HOME}

ENV JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m

EXPOSE 8081

ENTRYPOINT [ "/uid_entrypoint" ]
CMD ["bin/nexus", "run"]
