---
title: Setup
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

There are four ways to get the program:

* download and run the setup program build for each release.
* download and extract the binaries build for each release.
* [build](build.html) the program from the sources.
* download and install the official package for a linux distribution.

In all the cases, the _DMD_ D2 compiler must setup and its location has to match to one of the directory of the PATH environment variable.
If it's not already installed, [download](http://dlang.org/download.html) and setup DMD2 for your platform.

Note that Windows releases are currently not well integrated to the project host.
The can be found on [AppVeyor](https://ci.appveyor.com/project/BBasile/dexed/history), from the _Artifacts_ tab visible when clicking one of item that listed.

For each platform Dexed can be setup using a setup program or by extracting the binaries.

## Linux dependencies

The official build of the software is based on the GTK2 toolkit.
The runtime libraries must be setup (libgtk2, libglib, libgdk-pixbuf2, etc; they usually comes together, libc).
To enhance the appearence, you can also setup some theme engines (such as Adwaita, Clearlooks, Nimbus, Industrial, etc).

## Setup program

**Note that this section contains obsolete links and should not be followed unless you put your hands on an old version of the setup program**

* Go to [the release page](https://github.com/Basile-z/dexed/releases),
* Choose the zipped setup for your platform (at the bottom of a release log, the buttons labeled `dexed.<version>.<platform>.setup.zip`).
* The content must be extracted and executed:
    * note that the option `--nodcd` can be typed to skip the installation of the completion daemon.
    * Linux, setup for all the users: in a console `cd` to the file location and type `sudo ./dexed.<version>.<platform>.setup`.
    * Linux, setup for the current user: in a console `cd` to the file location and type: `./dexed.<version>.<platform>.setup`.
    * Windows, optional, it may be necessary to deactivate your anti-virus software. Norton AV or McAfee hav been reported for detecting a potential threat.
    * Windows: double click, and confirm in the UAC dialog box.
* To uninstall, run the same program but with the `-u` option.
    * Linux: if Dexed has been setup with `sudo` you must also uninstall with elevated privileges: `sudo ./dexed.<version>.<platform>.setup -u`.
    * Windows: start a console as administrator and execute: `dexed.<version>.win32.setup -u`.
    * Troubleshooting: run the setup program with the `-l` (or `--list`) option to get the status of the files and use the report to uninstall manually the files or open a ticket [here][https://gitlab.com/basile.b/dexed/issues].

Note for the future versions:
* Updating doesn't require to uninstall.
* it's possible to uninstall from a newer setup program.
* always use the same privileges to uninstall or update as used previously.

## Binaries

**Note that this section contains obsolete links and should not be followed unless you put your hands on an old version of the zips containing the binaries**

* Go to [the release page](https://github.com/Basile-z/dexed/releases),
* Choose the binaries for your platform (at the bottom of an entry, the buttons labeled `dexed.<version>.<platform>.zip`).
* Extract the executables.
    * Linux: it's recommended to put them in `/home/<your account>/bin`, since it's a known system PATH and that it doesn't require the super user privileges.
    * Windows: the target folder must be added to your system PATH variable. When the location is not known the background tools won't work (symbol list, todo list, DCD).

Under Windows, the releases are compressed with the latest [7-zip beta](http://www.7-zip.org/) with the options _deflate-ultra_. In case of problem try to use 7zip.
Under Linux, the command line tool *zip* is used (_deflate_ and _-9_).

Under Linux you could have to set the files permission to allow their execution. This used to be necessary when
the early versions were all packed on Windows (files attributes were lost) but it shouldn't be the case anymore.

If they are not correctly set, for each of the following file **dexed**, **dcd-client**, **dcd-server**, **dastworx**, either set the permission in the context menu (check _allow execution_ or _executable_ depending on the desktop) or `chmod +x` the file in a console.

## Linux package

Are provided a _deb_ package (Debian and derived Ubuntu, Mint, etc) and a _rpm_ (Fedora, openSUSE), only for x86_64 (amd64).
After the installation, you must also build [DCD](features_dcd.html).

## First steps

- verify the [compilers paths](options_compilers_paths.html).
- check the information [about the tools](widgets_about.html).

<script>anchors.add();</script>
