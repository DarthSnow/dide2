---
title: Widgets - application options
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

The page exposes unsorted options. In the future some of them might be moved to their own category.

![](img/options_application.png)

- **additionalPATH**: Used to defined more paths were the background tools can be found. Each item must be separated by a path separator (`:` under Linux and `;` under Windows).
- **autoCheckUpdates**: If checked and if a newer release is available then a dialog proposes to open the matching html page on github.
- **autoCleanMRU**: If checked then the MRU lists wont display files that dont exist. When using a version control software or removable disk it can be preferable not to use this option.
- **autoKillProcThreshold**: When not zero this setting indicates the size of the stdandard output, in bytes, over which an inferior process gets killed automatically. By default set to 2 Mb. This is usefull for example to prevent issues when an inferior falls into an infinite loop that prints.
- **autoSaveProjectFiles**: If checked the sources are automatically saved before compilation.
- **consoleProgram**: Allows to set the terminal emulator used to execute programs. By default XTerm is used and an error can occur if it's not setup. The setting is used by the [runnable modules](features_runnables.html), the [custom tools](widgets_custom_tools.html) and the project launcher. Under Windows this option is not used.
- **coverModuleTests**: If checked then the coverage by the tests is measured and displayed in the messages after executing the action __File/Run file unittests__.
- **dcdPort**: Sets the port used by the [completion daemon](features_dcd.html) server. Under Windows `0` means the default value. Under GNU/Linux `0` means that a UNIX domain socket is used and any other number means that a TCP socket is used. This setting requires a restart.
- **dscanUnittests**: If checked the content of the `unittest` blocks are analyzed when using the action __File/Verify with Dscanner__. Do not activate if the results of the static analysis tend to generate irrelevant messages in the tests.
- **flatLook**: Doesn't draw the buttons shape unless they're hovered by the mouse.
- **floatingWidgetOnTop**: Keeps the widgets that are not docked on top of the application window.
- **maxReventDocuments**: Sets how many entries can be stored in __File/Open recent file__.
- **maxReventDocuments**: Sets how many entries can be stored in __Project/Open recent project__.
- **maxReventProjectsGroups**: Sets how many entries can be stored in __Projects group/Open recent group__.
- **nativeProjectCompiler**: Sets [which compiler](options_compilers_paths.html) is used to compile a project that has the [CE format](widgets_ce_project_editor.html).
- **reloadLastDocuments**: Sets if the sources, the project, and the group that were opened on exit are reloaded automatically.
- **showBuildDuration**: Sets if the duration of a project build is measured.
- **splitterScrollSpeed**: Sets how fast the splitters are moved when the scroll wheel is used.

<script>anchors.add();</script>
