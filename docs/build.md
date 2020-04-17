---
title: Build Dexed
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

Dexed is mostly programmed in Object Pascal, using the the [Lazarus development platform](http://www.lazarus-ide.org/).

* [Download](http://lazarus.freepascal.org/index.php?page=downloads) and setup the latest Lazarus version (2.0.5) and  FPC + FPC sources (3.0.4) for your platform.
    * Windows: the three packages are bundled in an installer.
    * Linux: the three packages must be downloaded and setup individually. It's recommended to download the packages from _SourceForge_ and not from the official repository of the distribution because they don't always propose the latest version.
* [Download](https://github.com/ldc-developers/ldc/releases) and setup LDC2, the LLVM-based D compiler. It is used to compile the part of IDE written in D, a library called _libdexed-d_. the binaries must be visible in the system PATH variable. Note that building _libdexed-d_ is automatic.
* `cd <user dir where to clone>`
* `git clone https://gitlab.com/basile.b/dexed.git`
* `git submodule update --init`, to clone the dependencies used by libdexed-d.

The Lazarus LCL and the FreePascal FCL may require patches that fix bugs or regressions present in the latest Lazarus release and for which Dexed cannot include workarounds.
Any `.patch` file located in the `patches/` folder should be applied. On linux you'll have to set the write permissions to `/usr/lib64/fpc` and `/usr/lib64/lazarus`.

You're now ready to build Dexed. This can be done in the IDE or using the _lazbuild_ utility.

* If you don't plan to develop the project, use _lazbuild_:
    * open a console.
    * `cd` to the repository location, sub folder **lazproj**.
    * type `lazbuild -B dexeddesigncontrols.lpk` and <kbd>ENTER</kbd>. Note that the path to _lazbuild_ may have to be specified.
    * type `lazbuild -B dexed.lpi` and <kbd>ENTER</kbd>. Note that the path to _lazbuild_ may have to be specified.

* If you plan to help developing you'd better get started with _Lazarus_, which is less conveniant:
    * start Lazarus.
    * setup `lazproj/cedsgncontrols.lpk` with Lazarus package manager (requires to rebuild Lazarus).
    * in the **project** menu, click *open...* and select the file **dexed.lpi**, which is located in the sub-folder **lazproj**.
    * in the menu **Execute** click **Create**.

After what Dexed should be build. The executable and the library are output to the _bin_ folder.
The library might have to be copied to a specific path, e.g _/lib64/_ under linux.
## Third party tools

Additionally you'll have to build [the completion daemon **DCD**](https://github.com/dlang-community/DCD#setup) and the [D linter **Dscanner**](https://github.com/dlang-community/Dscanner#building-and-installing).
See the products documentation for more information.

<script>anchors.add();</script>
