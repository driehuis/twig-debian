#!/usr/bin/env bash

set -e

# Respawn under bash if not running under bash
[ -z "$BASH_VERSION" ] && exec bash $0 "$@"

usage()
{
cat << EOF
  Usage: $0 options

  Downloads the upstream source of the Twig templating language and
  produces a Debian package file (.deb).

  Takes the version to download from the debian/changelog file
EOF
}

set -- `head -1 debian/changelog| sed -e 's/^[^(]*(//' -e 's/).*//' -e 's/-/ -/'`
VERSION=$1
DEBIAN_VERSION=$1$2

if [[ -z $VERSION ]]
then
  echo "debian/changelog does not start with a parseable version number, please fix"
  exit 1
fi

if [[ `grep -cF "($VERSION" debian/changelog` = 0 ]]
then
  echo "$VERSION is not listed in debian/changelog"
  exit 1
fi

GITHUB_URL="https://github.com/fabpot/Twig/tarball/v${VERSION}"
PACKAGE_NAME="twig"
TMP_DIR="/tmp"
TAR_FILE="${TMP_DIR}/${PACKAGE_NAME}_${VERSION}.orig.tar.gz"
EXTRACT_DIR="${TMP_DIR}/${PACKAGE_NAME}-${VERSION}"
DEB_FILE="${TMP_DIR}/${PACKAGE_NAME}_${DEBIAN_VERSION}_all.deb"
CURRENT_DIR=${PWD}

if [[ ! -e ${TAR_FILE} ]]
then
  wget ${GITHUB_URL} -O ${TAR_FILE}
fi

if [[ ! -e ${TAR_FILE} ]]
then
  echo 'Could not download file'
  exit 1
fi

if [[ -d ${EXTRACT_DIR} ]]
then
  rm -rf ${EXTRACT_DIR}
fi

mkdir ${EXTRACT_DIR}
tar --strip-components=1 -xzf ${TAR_FILE} -C ${EXTRACT_DIR}
mkdir -p ${EXTRACT_DIR}/debian/source
cp -r ${CURRENT_DIR}/debian/* ${EXTRACT_DIR}/debian/
chmod 755 "${EXTRACT_DIR}/debian/rules"
cd ${EXTRACT_DIR}
debuild -us -uc

cp ${DEB_FILE} ${CURRENT_DIR}/

