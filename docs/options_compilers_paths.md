---
title: Options - Compiler Paths
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

The _Compilers paths_ category is used to define the paths to the compilers and to their respective versions of the standard library.

These settings are important and should be verified after the installation.

![](img/compilers_paths.png)

Up to five D compilers can be defined.

* __DMD__: should be set to the stable DMD version. The paths are normally detected when _Dexed_ is launched for the first time.
* __GDC__: should be set to the stable GDC version.
* __LDC__: should be set to the stable LDC version.
* __User1__: can be set to any compiler, for the example the development version of DMD.
* __User2__: a second user-defined compiler.

The combo box at the top is used to select which are the paths passed to the [completion daemon](features_dcd.html).
If the completion daemon is launched by _Dexed_ then the change is applied directly after the validation, otherwise it has to be restarted manually.

The second combo box defines which of the 5 defined compiler matches to the _global_ alias. This way it's possible to change the compiler used in a single step, assuming that all the compilation contexts (runnable, DUB, dexed projects) are set to follow the _global_ alias.
In most of the cases this is not useful but was added to make easier testing experimental branches of DMD or the beta versions.

In other options categories one of these compilers or _global_ can be selected.

* Category _Application_, _nativeProjectCompiler_: defines the compiler used to compile a project that has the native format.
* Category [_Runnable modules_](features_runnables.html), _compiler_: defines the compiler used to compile a _runnable module_ or a DUB script.
* Category [_DUB build_](options_dub_build.html), _compiler_: defines the compiler used to compile a project that has the DUB format.

<script>anchors.add();</script>
