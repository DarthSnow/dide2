set -e

# env
export DC=ldc2
semver=$(cat setup/version.txt)
ver=${semver:1:100}
dcd_ver=""
dscanner_ver=""
echo "building dexed release" $ver

# libdexed-d shared objects
if [ ! -d "./bin" ]; then
    mkdir "./bin"
fi
DEXED_BIN_PATH=$(readlink --canonicalize "./bin")
SEARCH_PATH_LDC=$(find "/" -iname "libdruntime-ldc.a" 2>/dev/null | grep -m 1 "libdruntime")
SEARCH_PATH_LDC=$(dirname $SEARCH_PATH_LDC)
export LIBRARY_PATH="$LIBRARY_PATH":"$SEARCH_PATH_LDC":"$DEXED_BIN_PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"$SEARCH_PATH_LDC":"$DEXED_BIN_PATH"

# libdexed-d
cd dexed-d
dub build --build=release --compiler=ldc2
if [ ! -f "../bin/libdexed-d.so" ]; then
    echo "this explains linking issues..."
    exit 1
fi
cp "../bin/libdexed-d.so" "/lib64/libdexed-d.so"
cp "../bin/libdexed-d.so" "/lib/libdexed-d.so"
cd ..

# dexed
echo "building dexed..."
cd lazproj
lazbuild -B dexeddesigncontrols.lpk
lazbuild -B dexed.lpi
echo "...done"
cd ..

# dcd
echo "building dcd..."
if [ ! -d dcd ]; then
    git clone https://github.com/dlang-community/dcd.git
    cd dcd
    git submodule update --init
else
    cd dcd
    git pull
fi
git fetch --tags
if [ ! -z "$dcd_ver" ]; then
    git checkout $dcd_ver
fi
make ldc
echo "...done"
cd ..

# dscanner
echo "building dscanner..."
if [ ! -d d-scanner ]; then
    git clone https://github.com/dlang-community/d-scanner.git
    cd d-scanner
    git submodule update --init
else
    cd d-scanner
    git pull
fi
git fetch --tags
if [ ! -z "$dscanner_ver" ]; then
    git checkout $dscanner_ver
fi
make ldc
echo "...done"
cd ..

# move to setup dir
echo "moving files and binaries..."
if [ ! -d setup/nux64 ]; then
    mkdir setup/nux64
fi
mv bin/libdexed-d.so setup/nux64/
mv bin/dexed setup/nux64/
mv dcd/bin/dcd-server setup/nux64/
mv dcd/bin/dcd-client setup/nux64/
mv d-scanner/bin/dscanner setup/nux64/
cp logo/dexed.ico setup/nux64/dexed.ico
cp logo/dexed256.png setup/nux64/dexed.png
cp LICENSE_1_0.txt setup/nux64/dexed.license.txt
cp dcd/License.txt setup/nux64/dcd.license.txt
echo "...done"

# deb, rpm, custom console installer
cd setup
echo "building the RPM..."
bash rpm.sh
echo "...done"
echo "building the DEB..."
bash deb.sh
echo "...done"
SETUP_APP_NAME="dexed.$ver.linux64.setup"
echo "building the custom setup program..."
SETUP_DC=$DC
if [ "$SETUP_DC" = ldc2 ]; then
    SETUP_DC=ldmd2
fi
$SETUP_DC setup.d -O -release -Jnux64 -J./ -of"output/"$SETUP_APP_NAME
bash zip-nux64.sh
bash setupzip-nux-noarch.sh $SETUP_APP_NAME
echo "...done"

# the job executing this script is only triggered when
# - a tag is pushed
# - a merge request, since one might modify this script.
# so push a new release only in the first case.
if [ ! -z "$GITLAB_CI" ]; then

    # build links to the artifacts
    LNK_BASE="https://gitlab.com/basile.b/dexed/-/jobs/$CI_JOB_ID/artifacts/raw/setup/output/"
    RPM_NAME="dexed-$ver-0.x86_64.rpm"
    DEB_NAME="dexed-$ver.amd64.deb"
    ZP1_NAME="dexed.$ver.linux64.setup.zip"
    ZP2_NAME="dexed.$ver.linux64.zip"

    # read the log
    $DC extract_last_changelog_part.d
    LOG=$(./extract_last_changelog_part)
    LOG=$(echo "$LOG" | sed -z 's/\n/\\n/g' | sed -z 's/\"/\\"/g')

    ASSET_RPM='{ "name" : "'$RPM_NAME'" , "url" : "'$LNK_BASE$RPM_NAME'" , "filepath" : "/binaries/'$RPM_NAME'" }'
    ASSET_DEB='{ "name" : "'$DEB_NAME'" , "url" : "'$LNK_BASE$DEB_NAME'" , "filepath" : "/binaries/'$DEB_NAME'" }'
    ASSET_ZP1='{ "name" : "'$ZP1_NAME'" , "url" : "'$LNK_BASE$ZP1_NAME'" , "filepath" : "/binaries/'$ZP1_NAME'" }'
    ASSET_ZP2='{ "name" : "'$ZP2_NAME'" , "url" : "'$LNK_BASE$ZP2_NAME'" , "filepath" : "/binaries/'$ZP2_NAME'" }'

    # ASSET_RPM='{ "name" : "'$RPM_NAME'" , "url" : "'$LNK_BASE$RPM_NAME'" }'
    # ASSET_DEB='{ "name" : "'$DEB_NAME'" , "url" : "'$LNK_BASE$DEB_NAME'" }'
    # ASSET_ZP1='{ "name" : "'$ZP1_NAME'" , "url" : "'$LNK_BASE$ZP1_NAME'" }'
    # ASSET_ZP2='{ "name" : "'$ZP2_NAME'" , "url" : "'$LNK_BASE$ZP2_NAME'" }'

    REQ_DATA='{ "name" : "'$semver'", "tag_name": "'$semver'", "description": "'$LOG'", "assets": { "links": [ '$ASSET_RPM' , '$ASSET_DEB' , '$ASSET_ZP1' , '$ASSET_ZP2'] } }'

    # create Gitlab release
    if [ -z "$CI_MERGE_REQUEST_ID" ]; then
        curl -g --header 'Content-Type: application/json' \
                --header "PRIVATE-TOKEN: $PUB_DEXED_RLZ" \
                --data-raw "$REQ_DATA" \
                --request POST https://gitlab.com/api/v4/projects/15908229/releases
    fi
fi
