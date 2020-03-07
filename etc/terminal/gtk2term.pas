unit Gtk2Term;

{$mode delphi}

interface

{$ifdef lclgtk2}
  {$ifdef unix}
    {$define hasgtk2term}
  {$endif}
{$endif}

{$ifdef hasgtk2term}

uses
  GLib2, Gtk2, dynlibs, gdk2, pango;

type
  GPid = LongWord;
  PGPid = ^GPid;
  GError = LongWord;
  PGError = ^GError;

  TVtePtyFlags = LongWord;

const
  VTE_PTY_DEFAULT = $0;
  VTE_PTY_NO_LASTLOG = $1;
  VTE_PTY_NO_UTMP = $2;
  VTE_PTY_NO_WTMP = $4;
  VTE_PTY_NO_HELPER = $8;
  VTE_PTY_NO_FALLBACK = $10;

type
  TGSpawnFlags = LongWord;

const
  G_SPAWN_DEFAULT = $0;
  G_SPAWN_LEAVE_DESCRIPTORS_OPEN = $1;
  G_SPAWN_DO_NOT_REAP_CHILD = $2;
  G_SPAWN_SEARCH_PATH = $4;
  G_SPAWN_STDOUT_TO_DEV_NULL = $8;
  G_SPAWN_STDERR_TO_DEV_NULL = $10;
  G_SPAWN_CHILD_INHERITS_STDIN = $20;
  G_SPAWN_FILE_AND_ARGV_ZERO = $40;
  G_SPAWN_SEARCH_PATH_FROM_ENVP = $80;
  G_SPAWN_CLOEXEC_PIPES = $100;

type
  TGSpawnChildSetupFunc = procedure(user_data: Pointer); cdecl;

  PVteTerminal = ^TVteTerminal;
  TVteTerminal = record
    widget: PGtkWidget;
  end;

  VTE_TERMINAL = PVteTerminal;

  TVteSelectionFunc = function(terminal: PVteTerminal; column: glong; row: glong; data: Pointer): gboolean; cdecl;

var
  vte_terminal_new: function: PGtkWidget; cdecl;

  vte_terminal_fork_command_full: function(terminal: PVteTerminal; pty_flags: TVtePtyFlags;
    working_directory: PChar; argv, envv: PPChar; spawn_flags: TGSpawnFlags;
    child_setup: TGSpawnChildSetupFunc; child_setup_data: Pointer; child_pid:
    PGPid; error: PGError): GBoolean; cdecl;

  vte_terminal_set_color_background: procedure(terminal: PVteTerminal;
    const background: PGdkColor); cdecl;

  vte_terminal_set_color_foreground: procedure(terminal: PVteTerminal;
    const background: PGdkColor); cdecl;

  vte_terminal_set_color_bold: procedure(terminal: PVteTerminal;
    const background: PGdkColor); cdecl;

  vte_terminal_set_color_highlight: procedure(terminal: PVteTerminal;
    const background: PGdkColor); cdecl;

  vte_terminal_set_font: procedure(terminal: PVteTerminal;
    const font_desc: PPangoFontDescription); cdecl;

  vte_terminal_feed: procedure(terminal: PVteTerminal; data: PChar;
    length: PtrInt); cdecl;

  vte_terminal_feed_child: procedure(terminal: PVteTerminal; data: PChar;
    length: PtrInt); cdecl;

  vte_terminal_copy_clipboard: procedure(terminal: PVteTerminal); cdecl;

  vte_terminal_paste_clipboard: procedure(terminal: PVteTerminal); cdecl;

  vte_get_user_shell: function(): PChar;

  vte_terminal_get_row_count: function(terminal: PVteTerminal): glong; cdecl;

  vte_terminal_get_column_count: function(terminal: PVteTerminal): glong; cdecl;

  vte_terminal_get_cursor_position: procedure(terminal: PVteTerminal; column: Pglong; row: Pglong); cdecl;

  vte_terminal_get_text_range: function(terminal: PVteTerminal;
    start_row: glong; start_col: glong; end_row: glong; end_col: glong;
    is_selected: TVteSelectionFunc; user_data: Pointer; attributes: PGArray): PChar; cdecl;

  vte_terminal_get_adjustment: function(terminal: PVteTerminal): PGtkAdjustment; cdecl;

function Gtk2TermLoad: Boolean;

implementation

var
  vteInitialized: Boolean;
  vteLoaded: Boolean;

function bindFunction(var funcPtr: Pointer; const identifier: string; handle: TLibHandle): boolean;
begin
  funcPtr := GetProcAddress(handle, identifier);
  result  := funcPtr <> nil;
end;

function Gtk2TermLoad: Boolean;
const
  vteSoNames: array[0..1] of string = ('libvte.so', 'libvte.so.9');
var
  h: TLibHandle;
  n: string;
begin
  if vteInitialized then
    Exit(vteLoaded);
  vteInitialized := True;

  for n in vteSoNames do
  begin
    h := LoadLibrary(n);
    if h <> 0 then
      break;
  end;
  if h = 0 then
    exit(false);

  if not bindFunction(@vte_terminal_new,
    'vte_terminal_new', h) then
      exit(false);
  if not bindFunction(@vte_terminal_fork_command_full,
    'vte_terminal_fork_command_full', h) then
      exit(false);
  if not bindFunction(@vte_terminal_set_color_background,
    'vte_terminal_set_color_background', h) then
      exit(false);
  if not bindFunction(@vte_terminal_set_color_foreground,
    'vte_terminal_set_color_foreground', h) then
      exit(false);
  if not bindFunction(@vte_terminal_set_color_bold,
    'vte_terminal_set_color_bold', h) then
      exit(false);
  if not bindFunction(@vte_terminal_set_color_highlight,
    'vte_terminal_set_color_highlight', h) then
      exit(false);
  if not bindFunction(@vte_terminal_set_font,
    'vte_terminal_set_font', h) then
      exit(false);
  if not bindFunction(@vte_terminal_feed,
    'vte_terminal_feed', h) then
      exit(false);
  if not bindFunction(@vte_terminal_feed_child,
    'vte_terminal_feed_child', h) then
      exit(false);
  if not bindFunction(@vte_terminal_copy_clipboard,
    'vte_terminal_copy_clipboard', h) then
      exit(false);
  if not bindFunction(@vte_terminal_paste_clipboard,
    'vte_terminal_paste_clipboard', h) then
      exit(false);
  if not bindFunction(@vte_get_user_shell,
    'vte_get_user_shell', h) then
      exit(false);
  if not bindFunction(@vte_terminal_get_row_count,
    'vte_terminal_get_row_count', h) then
      exit(false);
  if not bindFunction(@vte_terminal_get_column_count,
    'vte_terminal_get_column_count', h) then
      exit(false);
  if not bindFunction(@vte_terminal_get_cursor_position,
    'vte_terminal_get_cursor_position', h) then
      exit(false);
  if not bindFunction(@vte_terminal_get_text_range,
    'vte_terminal_get_text_range', h) then
      exit(false);
  if not bindFunction(@vte_terminal_get_adjustment,
    'vte_terminal_get_adjustment', h) then
      exit(false);

  vteLoaded := true;
  result := vteLoaded;
end;
{$else}
implementation
{$endif}

end.
