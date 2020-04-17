# v3.9.0-dev

## Other

- Toolchain: removed he background tool _dastworx_ and replaced it with a library called _libdexed-d_. Although this will not change the user experience:
    - Thousands of system calls to create the process and read its streams are saved.
    - ddemangle not required anymore.
    - crash in the new library will be fatal, i.e the IDE will have to be relaunched, while previously the tool was launched again, without significant impact on the IDE.

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
