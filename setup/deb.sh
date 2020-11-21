ver=`cat version.txt`
ver=${ver:1:100}
dte=$(LC_TIME='en_EN.UTF-8' date -u +"%a %b %d %Y")
cp_trgt=$(pwd)/output

arch=`uname -m`
if [ $arch = "x86_64" ]; then
    arch="amd64"
else
    arch="i386"
fi

name=dexed-$ver.$arch

basdir=$HOME/$name/
cfgdir=$basdir/DEBIAN
bindir=$basdir/usr/bin
pixdir=$basdir/usr/share/pixmaps
shcdir=$basdir/usr/share/applications
libdir=$basdir/usr/lib

mkdir -p $basdir
mkdir -p $cfgdir
mkdir -p $bindir
mkdir -p $pixdir
mkdir -p $shcdir
mkdir -p $libdir

cp nux64/dexed $bindir
cp nux64/dexed.png $pixdir
cp nux64/libdexed-d.so $libdir

echo "[Desktop Entry]
Categories=Application;IDE;Development;
Exec=dexed %f
GenericName=dexed
Icon=dexed
Keywords=editor;Dlang;IDE;dmd;
Name=dexed
StartupNotify=true
Terminal=false
Type=Application" > $shcdir/dexed.desktop
 
cd $cfgdir 
echo "Package: dexed
Version: $ver
Section: devel
Priority: optional
Date: $dte
Architecture: $arch
Depends: bash, libc6, libgtk2.0-0, libvte9
Maintainer: Basile Burg <b2.temp@gmx.com>
Description: IDE for the D programming language" > control

cd $HOME
dpkg-deb --build $name
rm $HOME/$name -r -f
mv $name.deb $cp_trgt/$name.deb
