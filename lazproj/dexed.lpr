program dexed;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}//{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}//{$ENDIF}
  Interfaces, Forms, lazcontrols, runtimetypeinfocontrols, anchordockpkg,
  tachartlazaruspkg, u_sharedres, u_dexed_d, u_observer, u_libman,
  u_symstring, u_tools, u_dcd, u_main, u_writableComponent,
  u_inspectors, u_editoroptions, u_dockoptions, u_shortcutseditor, u_mru,
  u_processes, u_dialogs, u_dubprojeditor, u_controls, u_dfmt,
  u_lcldragdrop, u_stringrange, u_dlangmaps, u_projgroup, u_projutils,
  u_d2synpresets, u_dbgitf, u_ddemangle, u_dubproject,
  u_halstead, u_diff, u_profileviewer, u_semver, u_term, u_simpleget;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

