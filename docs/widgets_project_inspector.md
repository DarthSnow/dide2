---
title: Widgets - project inspector
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

The project inspector is used to

- select the project configuration.
- open sources in an new editor.
- add or remove source if the active project has the [CE format](features_projects.html).

![](img/project_inspector.png)

The following toolbar buttons are always available:

- ![](icons/arrow/arrow_update.png): Updates the list of sources files and auto fetch DUB dependencies when applicable.
- ![](icons/folder/folders_explorer.png): Sets if the sources are displayed in a tree rather than in a single node.

The following toolbar buttons are only visible for CE projects:

- ![](icons/file/document_add.png): Adds a D source to the project from a dialog. The new source is not directly opened in the editor. To add a file that is already edited, rather use **"Add file to project"** from the **File** menu.
- ![](icons/file/document_delete.png): Removes from the project the source that's selected in the tree.
- ![](icons/folder/folder_add.png) Adds a folder of D source to the project from a dialog. The procedure is recursive.
- ![](icons/folder/folder_delete.png) Removes from the project the sources files that stand in the same directory as the source selected in the tree.

Note that instead of using the dialogs to add files, it's also possible to drop items from a file explorer.

<script>
anchors.add();
</script>
