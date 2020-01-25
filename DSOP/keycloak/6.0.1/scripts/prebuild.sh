#!/bin/bash

VERSION=6.0.1
IMAGE_NAME=opensource/keycloak
IMAGE_DIGEST=sha256:7caca7d35749ebeade412cdbca5a899e9a9d9a59a872f5d1185c59d993004694
IMAGE_ID=3a6718ca4ee02c3a9e9f4a4982d40f04f3bbc2f4ee9b936459519ea125ab87a9
NEXUS_REGISTRY=nexus-docker.52.61.140.4.nip.io
NEXUS_TAG=${NEXUS_REGISTRY}/builder-${IMAGE_NAME}:${VERSION}

set -e

# pull builder image; no GPG/sha checks are necessary because an explicit content hash (i.e. image digest) is used
sudo podman pull docker.io/jboss/keycloak@${IMAGE_DIGEST}

# re-tag image for Nexus Registry
sudo podman tag ${IMAGE_ID} ${NEXUS_TAG}

# push newly tagged image
sudo podman push ${NEXUS_TAG}

# clean up, including all tags for image
sudo podman rmi --force ${IMAGE_ID}

# Image digest and ID can be retrieved by doing a `podman inspect` once you have pulled the Docker image by its tag on your local machine
