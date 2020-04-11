cd ../dexed-d

if [ "$1" == "RELEASE" ]; then
    dub build --build=release --compiler=ldc2
elif [ "$1" == "DEBUG" ]; then
    dub build --build=debug --compiler=ldc2
elif [ "$1" == "" ]; then
    dub build --compiler=ldc2
fi

cd ../lazproj
