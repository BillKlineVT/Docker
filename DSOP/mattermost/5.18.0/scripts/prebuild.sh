#!/bin/bash
set -e
set -x
# Prebuild Script to stage mattermost tar file in artifact repository
# Releases URL:
# - https://docs.mattermost.com/administration/version-archive.html
#################################################################################
# Mattermost Package Variables
PKG="mattermost"
EDITION="team"
PKG_VERS="5.18.0"
VENDOR="mattermost"
VENDOR_RELEASES_URL="https://releases.mattermost.com"
VENDOR_PGP_URL="https://keybase.io/mattermost/pgp_keys.asc"

# Hard Coded SHA/SIG (s)
PKG_TAR_SHA="26aefb24abb822a9eb73605819fdae4fa22a05035e23d2c089781c09cfde5946"

#################################################################################
# Build File Names
PKG_NAME="${PKG}-${EDITION}"
PKG_FILE_NAME="${PKG_NAME}-${PKG_VERS}-linux-amd64"
PKG_TAR="${PKG_FILE_NAME}.tar.gz"
PKG_TAR_SIG="${PKG_TAR}.sig"
PKG_TAR_ASC="${PKG_TAR}.asc"
PKG_TAR_SHA_FILE="${PKG_TAR}.asc"
BUNDLE="${PKG_NAME}-bundle.tar.gz"

# Build File Paths
STAGING_DIR="/tmp/${PKG_NAME}-build"
PKG_TAR_PATH="${STAGING_DIR}/${PKG_TAR}"
PKG_TAR_ASC_PATH="${STAGING_DIR}/${PKG_TAR_ASC}"
PKG_TAR_SHA_PATH="${STAGING_DIR}/${PKG_TAR_SHA_FILE}"

# Build File Paths
PKG_TAR_URL="${VENDOR_RELEASES_URL}/${PKG_VERS}/${PKG_TAR}"
PKG_SIG_URL="${VENDOR_RELEASES_URL}/${PKG_VERS}/${PKG_TAR_SIG}"

#################################################################################
# Nexus Repo Target & Auth Variables Required in Build Env
NEXUS_USERNAME="${NEXUS_USERNAME}"
NEXUS_PASSWORD="${NEXUS_PASSWORD}"
NEXUS_SERVER="${NEXUS_SERVER}/repository/dsop"

#For Local Testing:
NEXUS_SERVER="nexus-secure.levelup-dev.io/dsop"

# Artifact Repo Target Path:
NEXUS_SERVER_PATH="https://${NEXUS_SERVER}/${VENDOR}/${PKG_NAME}/${PKG_VERS}"

#################################################################################
# Var Lists
KEYS="\
    ${VENDOR_PGP_URL}
    "

ARTIFACTS="\
    ${PKG_TAR}
"

ARTIFACT_URLS="\
    ${PKG_TAR_URL}     \
    ${PKG_SIG_URL}     \
    "

KEYSERVERS="\
    keyserver.ubuntu.com                 \
    ha.pool.sks-keyservers.net           \
    hkp://keyserver.ubuntu.com:80
    "

# Address any download file inconsistencies
run_exceptions () {
  # Rename .sig & .key to .asc per standard practice
  mv ${PKG_TAR_SIG} ${PKG_TAR_ASC}
}

#################################################################################
# Change to staging directory
start_DIR=$(pwd)
[[ -d ${STAGING_DIR} ]] && rm -rf ${STAGING_DIR}
mkdir -p ${STAGING_DIR} && cd ${STAGING_DIR}

#################################################################################
# Download Artifacts
for artifact in ${ARTIFACT_URLS}; do
    curl -fkvSL ${artifact} -O
done

# Correct Naming Inconsistencies
run_exceptions

#################################################################################
# Validate SHA of Artifacts

  echo "${PKG_TAR_SHA} ${PKG_TAR}" | sha256sum --check --status
  [[ $? == 0 ]] && echo "SHA256 Verification Passed"

#################################################################################
# Download & Validate Signature of Artifacts

# Download GPG Keys
for key in ${KEYS}; do
    curl ${key} | gpg --import
done

# Validate Signature
gpg --verify ${PKG_TAR_ASC} ${PKG_TAR}

#################################################################################
# Bundle all files
tar -zcvf /tmp/${BUNDLE} ${STAGING_DIR}/*

#################################################################################
# SHASUM SHA256 && Verify All Parts
for artifact in ${BUNDLE} ; do
    sha256sum   ${artifact}       \
       | awk    '{print $1}'      \
       | tee   "${artifact}.sha256"
done

#################################################################################
# Push to Nexus Repo
run_curl () {
echo "Uploading $1 ..."
curl -k -fu ${NEXUS_USERNAME}:${NEXUS_PASSWORD} \
     -T     $2/$1                                \
            ${NEXUS_SERVER_PATH}/$1
}

for artifact in ${BUNDLE}; do
    [[ -f ${PKG_TAR_ASC_PATH} ]] && run_curl ${PKG_TAR_ASC} "${STAGING_DIR}"
    run_curl "${BUNDLE}" "/tmp/"
    run_curl "${artifact}.sha256" "${STAGING_DIR}"
done

#################################################################################
# Cleanup
cd     ${start_DIR}
rm -rf ${STAGING_DIR}
