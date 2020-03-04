---
title: Widgets - Profile Viewer
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

## Description

The _profile viewer_ widget displays the results stored in the _trace.log_ file that a software compiled with DMD outputs when it's compiled with the `-profile` switch.

![](img/profile_viewer.png)

The pie displays the weight of a each function for a particular criterion.
This criterion can be selected in the combo box that's located in the toolbar.

The list displays all the results, which can be inspected more accurately after sorting a column.

## Toolbar

- ![](icons/other/list.png): Loads the _trace.log_ file located in the project output path.
- ![](icons/folder/folder.png): Proposes to open the _trace.log_ from a dialog.
- ![](icons/arrow/arrow_update.png): Reloads the current _trace.log_ or tries to load it from the current directory.
- ![](icons/cog/wrench.png): Shows the profile viewer options.

## Options

- **hideAtributes**: Sets if the functions attributes are displayed.
- **hideRuntimeCalls**: When checked, all the functions starting with `core.` are excluded.
- **hideStandardLibraryCalls**: When checked, all the functions starting with `std.` are excluded.
- **otherExclusion**: Allows to define other sub-strings masks.

<script>anchors.add();</script>
