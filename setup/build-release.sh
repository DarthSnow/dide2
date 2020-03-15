set -e

# env
export DC=ldc2
semver=$(cat setup/version.txt)
ver=${semver:1:100}
echo "building dexed release" $ver

# dastworx
cd dastworx
bash build.sh
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
git clone https://github.com/dlang-community/dcd.git
cd dcd
git submodule update --init --recursive
git fetch --tags
make ldc
echo "...done"
cd ..

# dscanner
echo "building dscanner..."
git clone https://github.com/dlang-community/d-scanner.git
cd d-scanner
git submodule update --init --recursive
git fetch --tags
make ldc
echo "...done"
cd ..

# move to setup dir
echo "moving files and binaries..."
mkdir setup/nux64
mv bin/dastworx setup/nux64/
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
echo "building the DEV..."
bash deb.sh
echo "...done"
SETUP_APP_NAME="dexed.$ver.linux64.setup"
echo "building the custom setup program..."
ldmd2 setup.d -O -release -Jnux64 -J./ -of"output/"$SETUP_APP_NAME
bash zip-nux64.sh
bash setupzip-nux-noarch.sh $SETUP_APP_NAME
echo "...done"

# the job executing this script is only triggered when
# - a tag is pushed
# - a merge request, since one might modify this script.
# so push a new release only in the first case.
if [ ! -z "$GITLAB_CI" ]; then

    # build links to the artifacts
    # reminder: need to set the expiration date or click KEEP btn on the website UI
    LNK_RPM=https://gitlab.com/basile.b/dexed/-/jobs/$CI_JOB_ID/artifacts/raw/setup/output/dexed-3.8.0-0.x86_64.rpm
    LNK_DEB=https://gitlab.com/basile.b/dexed/-/jobs/$CI_JOB_ID/artifacts/raw/setup/output/dexed-3.8.0.amd64.deb
    LNK_ZP1=https://gitlab.com/basile.b/dexed/-/jobs/$CI_JOB_ID/artifacts/raw/setup/output/dexed.3.8.0.linux64.setup.zip
    LNK_ZP2=https://gitlab.com/basile.b/dexed/-/jobs/$CI_JOB_ID/artifacts/raw/setup/output/dexed.3.8.0.linux64.zip

    echo "asset1: " $LNK_RPM
    echo "asset2: " $LNK_DEB
    echo "asset3: " $LNK_ZP1
    echo "asset4: " $LNK_ZP2

    # create Gitlab release
    if [ ! -z "$CI_MERGE_REQUEST_ID" ]; then

        curl --header 'Content-Type: application/json' \ --header "PRIVATE-TOKEN:" $CI_JOB_TOKEN \
            --data '{ "name": "Dexed '$ver'", "tag_name": '$semver', "description": "changelog coming soon...",' \
            '"assets": { "links": [{"url": "'$LNK_RPM'" }, {"url": "'$LNK_DEB'" }, {"url": "'$LNK_ZP1'" }, {"url": "'$LNK_ZP2'" }] } }' \
            --request POST https://gitlab.com/api/v4/projects/15908229/releases
    fi
fi
