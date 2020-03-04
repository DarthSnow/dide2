---
title: Widgets - Mini Explorer
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

## Description

The mini explorer provides basic file browsing functionality within the IDE.

![](img/mini_explorer.png)

- ![](icons/folder/folder_go.png): When clicked, allows to select a custom tree root. When using the associated drop down, allows to select a particular drive as root.
- ![](icons/arrow/go_previous.png): Got to the root parent folder.
- ![](icons/folder/folder_add.png): Adds the selected folder to the favorites.
- ![](icons/folder/folder_delete.png): Removes the selected favorite folder.
- ![](icons/other/flash.png): Open the selected folder or execute the selected file using the shell.
- ![](icons/other/pencil.png): If the selected file is a CE or a DUB project then opens it as a project otherwise opens it in a new code editor.
- ***input field***: filter the files whose name contains the text typed.

The file list supports drag and drop.

## Options

A few options are available in the [option editor](widgets_options_editor.html).

![](img/options_mini_explorer.png)

- **contextExpands**: If checked then the tree auto expands to the folder that contains the source or the project file that's been focused.
- **doubleClick**: Defines what happens when a file is double clicked.
- **showHidden**: Sets if hidden folders and files are displayed.

<script>anchors.add();</script>
