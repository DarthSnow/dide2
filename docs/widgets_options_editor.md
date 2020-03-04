---
title: Widgets - Options Editor
header-includes: <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.2.2/anchor.min.js"></script>
---

The _Options editor_ is a special, non-dockable, widget that allows the other widgets to expose their options.
The list at the left displays the categories. A category often matches to a single widget but not only (for example the shortcuts).

![](img/options_application.png)

The options are applied in real time but are reversible until the green checker icon is clicked.

- ![](icons/other/accept.png): Validates the modifications made to the current category, after what they can't be canceled anymore.
- ![](icons/other/cancel.png): Cancels and restores the previous state of the current category.

The options are persistent and saved in a specific folder:

- Linux:
**`/home/<your account>/.config/Coedit/`**.
- Windows:
**`?:\Users\<your account>\AppData\Roaming\Coedit\`**.

Each software component saves its own file with a self-explanatory name so it's easy to find and modify the file that matches a particular setting.

<script>anchors.add();</script>
