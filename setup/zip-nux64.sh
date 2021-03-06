ver=`cat version.txt`
fld=dexed-x86_64
cd nux64
mkdir $fld/
cp * $fld/
zip -9 \
../output/dexed.${ver:1:100}.linux64.zip \
$fld/dcd.license.txt $fld/dexed.license.txt \
$fld/dexed $fld/libdexed-d.so \
$fld/dexed.ico $fld/dexed.png \
$fld/dcd-server $fld/dcd-client $fld/dscanner
rm -rf dexed-x86_64
