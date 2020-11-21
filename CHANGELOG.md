# v3.9.9-dev

## Enhancement

- GDB commander: The widget is now activated on Windows systems. Note that it might only works if the project is compiled with LDC >= 1.23.0 and if debug info  are generated and if the _-gdwarf_ switch is also part of the config.
See [LDC announcement](https://forum.dlang.org/post/ssvxmrdpklhsrqlgrzas@forum.dlang.org). GDB for windows can be found [here](https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2064%20bits/Alternative%20GDB/) for example.

## Bugs fixed

- Messages, when selected, the recently added _Search Results_ category could not be emptied.
- Highlighter, `q"()"`, `q"[]"`, `q"<>"`, `q"{}>"` strings highlighting was broken.
- HTML export, the dialog proposed to open a file, not to save one.
- Setup, the deb package had problem on newest Ubuntu. (#72)

# v3.9.8

## Enhancements

- Messages, searches: results of _Find All_ with for scope a whole project go in their own category, preventing to repeat the operation in certain circumstances. (#60)
- Project inspector: moved the list of configuration to a combo box located over the file tree.

## Bugs fixed

- GDB commander, editor: bad expression returned when using mouse motion to get value of an expression located within square brackets.

## Other

- Release links error 404. This is due to an old problem of Gitlab but that unfortunately got worse by the end of August...

# v3.9.7

## Enhancements

- Project menu, git: add the first line of last commit message as additional information, between square brackets, to the items of the list of branches. (#53)
- Symbol list: keep errors and warnings at the top of the tree and never sort these two categories, to respect the lexicographic order. (#58)

## Regressions fixed

- Messages, the messages matching to the call stack printed on assert failure were not clickable anymore. The regression was introduced when the support for GNU-style messages was added.
- Segfault on exit since built with FPC 3.2.0. (#54)

## Bugs fixed

- Editor: module name not displayed in the tab caption if the module has the shebang line.
- Project menu, git: no label in the list of branches when in "detached HEAD" after a checkout.

## Other

- compilation: FPC 3.2.0 now required to compile dexed.
- It is recommended to deactivate the automatic update of the _Todo List_ widget, due to [a crasher](https://gitlab.com/basile.b/dexed/-/issues/55)

# v3.9.6

## Enhancements

- D highlighter: added option to highlights function calls and function definition. Use options window: _Editor/HighlighterDlang/calls_ to test it as by default the same properties as identifiers are used.
- GDB commander: added the _maxCallStackDepth_ option. It prevents slowdowns, especially after an automatic break on SEGFAULT caused by a stack overflow.

## Bugs fixed

- Editor: wrong position indicated in the call tips when starting to type an array literal, a slice or any other expression involving the square brackets. (#51)
- Project Menu, Git: active branch was not updated after an external checkout.

# v3.9.5

## Enhancements

- GDB commander: added a 3rd choice in the menu associated to first toolbar button. It allows to debug a custom executable, i.e not tied to a project or a runnable script.

## Regressions

- DUB project: when compiling a DUB project with LDC, LDC was translated to LDMD. (#47, caused by the fix for #43)
- Options, shortcut editor: The view was empty until something got typed and then deleted in the filter. (#49)

## Bugs fixed

- Terminal: Scrollbar out of range exception, optionally freezing the IDE, when interactive program launched (e.g vi). (#46)

# v3.9.4

## Enhancements

- D highlighter: highlight `@()` just like `@Identifier` ans skipping the enclosed content. Nested `@()` are not handled.

## Bugs fixed

- GDB commander: automatic break on exception did not work if the program was compiled with LDC2. (#41)
- GDB commander: expressions obtained by mouse motion were not correct when the source used tabulations to indent. (#42)
- Messages: force auto scrolling to bottom once and if the messages context is modified.
- Runnables: ldc2 was not translated to ldmd when the "global compiler" was set to compile the runnables. (#43)
- Terminal: after launching dexed, the current directory was not constrained even when the settings to follow the current project or document path were activated. (#5)
- Terminal: problem with the min position of the scrollbar. Visible for example when a program output more lines then the *scrollbackLines* setting.
- Windows: fixed broken compilation that was caused by libdexed-d.

# v3.9.3

## Enhancements

- Messages: only auto scroll on new message if the bottom-most message is in view, like in terminal emulators. (#39)
- Messages: enhanced detection patterns to open a file from a message. The new detections are for messages containing a filename of the project, relative to _src_ or _src_ instead of the project root directory.

## Bugs fixed

- libdexed-d: reduce memory usage caused by D allocations. (#38)

# v3.9.2

## Regressions

- Symbol list: performance regression, async behavior is now emulated with threads. (#35)
- Todolist: performance regression, async behavior is now emulated with threads. (#35)
- Todolist: small non growing leak introduced in v3.9.0

## Bugs fixed

- Editor, Diff: the button used to "reload from disk and reset the history" didn't work.

# v3.9.1

## Bugs fixed

- Other: Sigsegv upon starting dexed. (#33)
- Other: the setting files could be corrupted when values contained mutli-bytes UTF-8 characters. (#19)
- installers: fix the _rpm_ package since it required a dependency specific to the gitlab runner used to release.

## Other

- installers: adjusted the _.deb_ package to make it compatible with both Debian and Ubuntu. (#33) 

# v3.9.0

## Enhancements

- D highlighter: added suport for HEREDOC string literald of type `q"()"` `q"[]"`, `q"<>"` and `q"{}"`. Support for HEREDOC based on a custom delimiter wont be added as they might be removed as per DIP 1026.
- Docking: added a dialog to remind that docking is locked in certain scenarios. (#30)
- Editor: the option to detect the indentation is activated by default, to prevent mixed indentation style.
- Editor: a fourth button in the diff dialog allows to reload but without preserving the undo history, which is better when using _go to next changed area_ and _go to prev changed area_ to navigate in the editor.
- Search Replace: the result of _FindAll_ when the string to search is not a trivial regular expression are also highlighted. (#14)
- TODO list: a new option, _disableIfMoreFilesThan_, allows to disable auto refreshing of the list could be slow when the current project is huge.

## Bugs fixed

- DUB projects: dependencies specified with _path_ and with their sources located in "src" or "source" were not passed correctly to DCD. (#29)
- DUB projects: dependencies specified with _path_ are recognized when their sources are in a sub folder taking as name the package name. (#29)
- DUB runnables: document specific messages were not cleared between two calls to "Run DUB single file package". (#27)
- Editor: case where brace auto close is triggered while in comment. (#31)
- Editor: prevent unexpected validation of properties in certain cases, such as `a.map` giving `a.mangleof!` after `!`.

## Other

- Toolchain: removed the background tool _dastworx_ and replaced it with a statically linked shared library called _libdexed-d_.
- Toolchain: ddemangle is not required anymore, demangling of D names now happens in _libdexed-d_.

# v3.8.4

## Bugs fixed

- Editor, calltips: problem when the function parameter included type constructors. (#26)

## Other

- Project CI: extraction of the changelog didn't work properly.

# v3.8.3

## Enhancements

- Compiler paths: when selecting the ldc2 compiler file the matching library path is added if it's "../import". (#20)
- Compiler paths: better messages when trying to use a compiler that's not defined. (#18)

## Bugs fixed

- Widgets, option: problem with the option "floating widgets on top". (#3)
- Misc: update checker was not updated to work with gitlab. (#21)

# v3.8.2

## Enhancements

- Custom tools: A new property allows to set the background color of the item. (#16)
- Custom tools: A new Toolbar button has for effect to terminate the process associated to a tool. (#15)
- Messages, added an option, enabled by default, allowing to highlight the blocks enclosed by backticks. This works for the "find all" action, the compiler output, the custom tools output, etc. (#13)

## Bugs fixed

- Editor, Calltips: the position of the window was incorrect when the arguments stood on several lines. (#10)
- Terminal, UI: the scrollbar lacked of accuracy. (#11)

## Other

- project CI: the release process is now fully automated, allowing painless and more frequent releases.

# v3.8.1

- dummy release

# v3.8.0

## Enhancements

- Compiler paths: added the "global" compiler. It allows to quickly set the compiler used whatever is the context.
- Compiler paths: the editors for LDC and GDC are less confusing now, since only one path is needed to specify the std/core paths, unlike for DMD.
- Editor, Calltips: in the call tips window, the parameter being edited is highlighted. Note that stacking of calltips in nested function calls is for now removed.
- GDB commander, editor, linux: it is now possible to inspect the variables in a tooltip window displayed when moving the mouse in the code editor.
- Messages: added support for GNU type messages. Note that the detection of the type (GNU or legacy DMD) is dynamic.
- MRUs: added an option preventing to remove non existing items, which used to be problematic when using git branches.
- Terminal, UI: added scrollbar.

## Bugs fixed

- Application, energy consumption: damped a small but constant CPU load, even on idle, caused by several timers.
- DUB project editor: it was possible to add a property twice.
- Editor: possible range violation when trying to rename an editor past the EOL.
- GDB Commander: no scrollbar in the variable inspector.
- Main menu: shortcuts for the tools not updated after editing the options.
- Terminal: clearing a temporary line because of automatic check dir caused a reset, clearing the backbuffer.

## Other

- the documentation is updated to be rendered by Gitlab CI or locally, with pandoc.
- windows binaries are not provided anymore.
