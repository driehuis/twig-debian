#!/usr/bin/env bash

set -e

# Respawn under bash if not running under bash
[ -z "$BASH_VERSION" ] && exec bash $0 "$@"

die() {
	echo "$0:" "$@" >&2
	echo unknown
	exit 1
}

os_rel=
[ "$os_rel" = "" ] && [ -f /etc/lsb-release ] && os_rel=`grep DISTRIB_CODENAME /etc/lsb-release | cut -d= -f2`
[ "$os_rel" = "" ] && [ -f /etc/debian_version ] && os_rel=`cat /etc/debian_version`
[ "$os_rel" = "" ] && die "No Debian version found"

case $os_rel in
	karmic) ;;
	lucid) ;;
	maverick) ;;
	natty) ;;
	oneiric) ;;
	precise) ;;
	quantal) ;;
	raring) ;;
	3.1)	os_rel=sarge ;;
	4.0)	os_rel=etch ;;
	5.0*)	os_rel=lenny ;;
	6.0*)	os_rel=squeeze ;;
	*) die "Unsupported Debian release $os_rel" ;;
esac

sed -e "s/\[distro\]/$os_rel/g" <debian/changelog.in >debian/changelog

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

php_extension_dir=`php-config --extension-dir | sed -e 's/^\///'`
echo $php_extension_dir >>debian/twig-bin.dirs

#debuild -us -uc
debuild -S

#cp ${TMP_DIR}/${PACKAGE_NAME}[-_]*.deb ${CURRENT_DIR}/
rm ${CURRENT_DIR}/debian/changelog
