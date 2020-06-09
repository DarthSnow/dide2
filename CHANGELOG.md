# v3.9.5-dev

## Enhancements

- GDB commander: added a 3rd choice in the menu associated to first toolbar button. It allows to debug a custom executable, i.e not tied to a project or a runnable script.

## Bugs fixed

- Terminal: Scrollbar out of range exception plus possible freeze. (#46)

# v3.9.4

## Enhancements

- D highlighter: highlight `@()` just like `@Identifier` ans skipping the enclosed content. Nested `@()` are still not handled.

## Bugs fixed

- GDB commander: automatic break on exception did not work if the cprogram was compiled with LDC2. (#41)
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
