This folder contains the files necessary to manually build dexed and its toolchain or to build a dexed release

## Requirements

### Building

- git
- Freepascal 3.0.4
- Lazarus 2.0.8
- ldc2

### Releasing

Same tools as to build plus:

- rpm
- dpkg
- zip

## Build manually dexed and the toolchain

- in the project root directory `bash setup/build-release.sh`

## Building a dexed release

- add a git tag, update the occurences of the tag in the main readme.
- change the content of the _version.txt_ accordingly.
- in the project root directory `bash setup/build-release.sh`

The installers are produced in the _output_ directory.
