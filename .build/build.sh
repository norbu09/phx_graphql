#!/bin/sh -e

NAME=phx_graphql

cd `dirname $0`
ROOT=`pwd -P`/..
BUILD=${ROOT}/_build/prod/rel
cd -
# clean up any existing releases
rm -rf ${BUILD}/${NAME}
# UTF8 while we build
LANG=en_US.UTF-8
LC_ALL=${LANG}
APP_VERSION=`date -u +%Y.1%m.1%d%H%M` && export APP_VERSION=${APP_VERSION}
MIX_ENV=prod mix do compile, phx.digest, release --env=prod
RELEASE=$(find ${BUILD} -name ${NAME}.tar.gz)

# use a random temporary dir for everything else
BASE=`mktemp -d /tmp/${NAME}.XXXXXX` || exit 1
STAGING=${BASE}/staging
DEST=${STAGING}/usr/local/lib/${NAME}
ETC=${STAGING}/usr/local/etc
PKG=${BASE}/package
MANIFEST=${PKG}/manifest.ucl

mkdir -p -m0750 ${PKG} ${DEST} ${ETC}/${NAME}

# exclude non-root users during tar etc
umask 027
# get template manifest and other static files
cp -av ${ROOT}/.build/templates/rc.d ${ETC}/
cp -av ${ROOT}/.build/templates/manifest.ucl ${MANIFEST}

# unpack the mix release itself excluding files with tokens
tar xzf ${RELEASE} \
    -C ${DEST} \
    --exclude sys.config \
    --exclude vm.args

# prepare FreeBSD package manifest
## grab the version number from mix
GIT_REF=$(git describe --dirty --abbrev=7 --tags --always --first-parent 2>/dev/null || true)
## inject all that into the manifest
uclcmd set --file ${MANIFEST} --type string version ${APP_VERSION}
uclcmd set --file ${MANIFEST} --type string gitref  ${GIT_REF}
# this step should ensure every package build is different
echo $GIT_REF > ${ETC}/${NAME}/gitref.tag

# include each file, its hash, and any permissions:
# expected result:
# /usr/lib/${NAME}/bin/${NAME}: {sum: 1$abc123, uname: root, gname: www, perm: 0440 }
SHA_LIST=$(find ${STAGING} -type f -exec sha256 -r {} + \
    | awk '{print "  " $2 ": {uname: root, gname: www, sum: 1$" $1"}"}')
# include softlinks:
# expected result looks like:
#   /usr/local/lib/symlink: -
LINKS_LIST=$(find ${STAGING} -type l \
    | awk '{print "  " $1 ": -"}')
# include ${NAME}-specific directories and permissions:
# make sure we exclude things like /usr /usr/local/ /etc/ that are
# already in place as we don't want to change their permissions
# expected result looks like:
#   /usr/local/lib/${NAME}: {uname: root, gname: www, perm: 0550}`
DIR_LIST=$(find ${STAGING} -type d -mindepth 3 -path \*/${NAME}/\*  \
    | awk '{print " " $1 ": {uname: root, gname: www, perm: 0750}"}')

# strip off _build/state prefix and append this UCL snippet to manifest
cat <<UCL | sed -E -e s:${STAGING}:: >> ${MANIFEST}
files: {
$SHA_LIST
$LINKS_LIST
}
directories: {
$DIR_LIST
}
UCL

## bubblewrap the package and manifest
pkg create --verbose \
    --root-dir ${STAGING} \
    --manifest ${MANIFEST} \
    --out-dir ${BUILD}
cp ${MANIFEST} ${BUILD}/
cat << EOF
to install:

sudo -s
service ${NAME} stop
pkg install $(find ${BUILD} -name ${NAME}\*.txz | head -n 1)
service ${NAME} start

final manifest:   $(find ${BUILD} -name manifest.ucl)
package complete: $(find ${BUILD} -name ${NAME}\*.txz | head -n 1)
EOF

cp `echo -n $(find ${BUILD} -name ${NAME}\*.txz | head -n 1)` ${ROOT}/.build/${NAME}.latest.txz
