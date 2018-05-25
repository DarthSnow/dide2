unit ce_editoroptions;

{$I ce_defines.inc}

interface

uses
  Classes, SysUtils, Graphics, SynEdit, SynEditMouseCmds, SynEditMiscClasses,
  SynEditKeyCmds, Menus, LCLProc,
  ce_interfaces, ce_observer, ce_common, ce_writableComponent, ce_synmemo,
  ce_d2syn, ce_txtsyn;

type

  (**
   * Container for the editor and highlither options.
   * The base class is also used to backup the settings
   * to allow a to preview and restore the settings when rejected.
   *
   * note: when adding a new property, the default value must be set in
   * the constructor according to the default value of the member binded
   * to the property.
   *)
  TCEEditorOptionsBase = class(TWritableLfmTextComponent)
  private
    // note this is how a TComponent can be edited in
    // a basic TTIGrid: in the ctor create the component
    // but expose it as a published TPersistent.
    fD2Syn: TPersistent;
    fTxtSyn: TPersistent;
    //
    fShortCuts: TCollection;
    //
    fDetectIndentationMode: boolean;
    fCurrLineAttribs: TSynSelectedColor;
    fSelAttribs: TSynSelectedColor;
    fFoldedColor: TSynSelectedColor;
    fMouseLinkAttribs: TSynSelectedColor;
    fBracketMatchAttribs: TSynSelectedColor;
    fIdentifierMarkup: TSynSelectedColor;
    fFont: TFont;
    //
    fResetFontSize: boolean;
    fIdentiMatchOpts: TIdentifierMatchOptions;
    fLineNumEvery: Integer;
    fDDocDelay: Integer;
    fAutoDotDelay: Integer;
    fTabWidth: Integer;
    fBlockIdent: Integer;
    fLineSpacing: Integer;
    fCharSpacing: Integer;
    fRightEdge: Integer;
    fBackground: TColor;
    fRightEdgeColor: TColor;
    fOptions1: TSynEditorOptions;
    fOptions2: TSynEditorOptions2;
    fMouseOptions: TSynEditorMouseOptions;
    fCompletionMenuCaseCare: boolean;
    fCompletionMenuAutoClose: boolean;
    fCompletionMenuWidth: integer;
    fCompletionMenuLines: Byte;
    fAutoCloseCurlyBrace: TBraceAutoCloseStyle;
    fPhobosDocRoot: TCEPathname;
    fAlwaysAdvancedFeatures: boolean;
    fAutoClosedPairs: TAutoClosePairs;
    fSmartDdocNewline: boolean;
    fInsertPlusDdoc: boolean;
    fAutoCallCompletion: boolean;
    fCloseCompletionCharsWithSpace: AnsiString;
    fCloseCompletionChars: AnsiString;
    fTransparentGutter: boolean;
    fDscannerDelay: integer;
    fDscannerEnabled: boolean;
    fScrollPreview: boolean;
    //
    procedure setPhobosDocRoot(value: TCEPathname);
    procedure setFont(value: TFont);
    procedure setSelCol(value: TSynSelectedColor);
    procedure setFoldedColor(value: TSynSelectedColor);
    procedure setMouseLinkColor(value: TSynSelectedColor);
    procedure setBracketMatchColor(value: TSynSelectedColor);
    procedure setIdentifierMarkup(value: TSynSelectedColor);
    procedure setCurrLineAttribs(value: TSynSelectedColor);
    procedure setD2Syn(value: TPersistent);
    procedure setTxtSyn(value: TPersistent);
    procedure setShortcuts(value: TCollection);
    procedure setDDocDelay(value: Integer);
    procedure setDscannerDelay(value: Integer);
    procedure setAutoDotDelay(value: Integer);
    procedure setCompletionMenuLines(value: byte);
    procedure setLineNumEvery(value: integer);
  published
    property alwaysAdvancedFeatures: boolean read fAlwaysAdvancedFeatures write fAlwaysAdvancedFeatures;
    property autoCallCompletion: boolean read fAutoCallCompletion write fAutoCallCompletion;
    property autoCloseCurlyBrace: TBraceAutoCloseStyle read fAutoCloseCurlyBrace write fAutoCloseCurlyBrace default TBraceAutoCloseStyle.autoCloseNever;
    property autoClosedPairs: TAutoClosePairs read fAutoClosedPairs write fAutoClosedPairs default[];
    property autoDotDelay: integer read fAutoDotDelay write SetautoDotDelay;
    property background: TColor read fBackground write fBackground default clWhite;
    property blockIndentation: Integer read fBlockIdent write fBlockIdent default 4;
    property bracketMatch: TSynSelectedColor read fBracketMatchAttribs write setBracketMatchColor;
    property characterSpacing: Integer read fCharSpacing write fCharSpacing default 0;
    property closeCompletionCharsWithSpace: AnsiString read fCloseCompletionCharsWithSpace write fCloseCompletionCharsWithSpace;
    property closeCompletionChars: AnsiString read fCloseCompletionChars write fCloseCompletionChars;
    property completionMenuAutoClose: boolean read fCompletionMenuAutoClose write fCompletionMenuAutoClose;
    property completionMenuCaseCare: boolean read fCompletionMenuCaseCare write fCompletionMenuCaseCare;
    property completionMenuLines: byte read fCompletionMenuLines write setCompletionMenuLines;
    property completionMenuWidth: integer read fCompletionMenuWidth write fCompletionMenuWidth;
    property currentLine: TSynSelectedColor read fCurrLineAttribs write setCurrLineAttribs;
    property ddocDelay: Integer read fDDocDelay write setDDocDelay;
    property dscannerDelay: integer read fDscannerDelay write setDscannerDelay;
    property dscannerEnabled: boolean read fDscannerEnabled write fDscannerEnabled;
    property detectIndentMode: boolean read fDetectIndentationMode write fDetectIndentationMode;
    property folding: TSynSelectedColor read fFoldedColor write setFoldedColor;
    property font: TFont read fFont write setFont;
    property highlighterDlang: TPersistent read fD2Syn write setD2Syn;
    property highlighterGeneric: TPersistent read fTxtSyn write setTxtSyn;
    property identifierMatch: TSynSelectedColor read fIdentifierMarkup write SetIdentifierMarkup;
    property identifierMatchOptions: TIdentifierMatchOptions read fIdentiMatchOpts write fIdentiMatchOpts default [caseSensitive];
    property lineNumberEvery: integer read fLineNumEvery write setLineNumEvery default 5;
    property lineSpacing: Integer read fLineSpacing write fLineSpacing default 0;
    property mouseLink: TSynSelectedColor read fMouseLinkAttribs write setMouseLinkColor;
    property mouseOptions: TSynEditorMouseOptions read fMouseOptions write fMouseOptions;
    property options1: TSynEditorOptions read fOptions1 write fOptions1;
    property options2: TSynEditorOptions2 read fOptions2 write fOptions2;
    property phobosDocRoot: TCEPathname read fPhobosDocRoot write setPhobosDocRoot;
    property plusDdoc: boolean read fInsertPlusDdoc write fInsertPlusDdoc;
    property resetFontSize: boolean read fResetFontSize write fResetFontSize default true;
    property rightEdge: Integer read fRightEdge write fRightEdge default 80;
    property rightEdgeColor: TColor read fRightEdgeColor write fRightEdgeColor default clSilver;
    property selection: TSynSelectedColor read fSelAttribs write setSelCol;
    property shortcuts: TCollection read fShortCuts write setShortcuts;
    property scrollPreview: boolean read fScrollPreview write fScrollPreview;
    property smartDdocNewline: boolean read fSmartDdocNewline write fSmartDdocNewline;
    property tabulationWidth: Integer read fTabWidth write fTabWidth default 4;
    property transparentGutter: boolean read fTransparentGutter write fTransparentGutter default false;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    procedure Assign(source: TPersistent); override;
  end;

  (**
   * Manages and exposes all the editor and highligther options to an TCEOptionsEditor.
   * It's also responsible to give the current options to a new editor.
   *)
  TCEEditorOptions = class(TCEEditorOptionsBase, ICEEditableOptions, ICEDocumentObserver, ICEEDitableShortcut)
  private
    fBackup: TCEEditorOptionsBase;
    fShortcutCount: Integer;
    //
    function optionedWantCategory(): string;
    function optionedWantEditorKind: TOptionEditorKind;
    function optionedWantContainer: TPersistent;
    procedure optionedEvent(event: TOptionEditorEvent);
    function optionedOptionsModified: boolean;
    //
    procedure docNew(document: TCESynMemo);
    procedure docFocused(document: TCESynMemo);
    procedure docChanged(document: TCESynMemo);
    procedure docClosing(document: TCESynMemo);
    //
    function scedWantFirst: boolean;
    function scedWantNext(out category, identifier: string; out aShortcut: TShortcut): boolean;
    procedure scedSendItem(const category, identifier: string; aShortcut: TShortcut);
    procedure scedSendDone;
    //
    procedure applyChangeToEditor(anEditor: TCESynMemo);
  protected
    procedure afterLoad; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure applyChangesFromSelf;
  end;

var
  EditorOptions: TCEEditorOptions;

implementation

const
  edoptFname = 'editor.txt';

{$REGION Standard Comp/Obj -----------------------------------------------------}
constructor TCEEditorOptionsBase.Create(AOwner: TComponent);
var
  i: integer;
  shc: TCEPersistentShortcut;
  ed: TSynEdit;
begin
  inherited;
  //
  fPhobosDocRoot := 'https://dlang.org/phobos/';
  fFont := TFont.Create;
  {$IFDEF WINDOWS}
  fFont.Name := 'Consolas';
  {$ELSE}
  fFont.Name := 'DejaVu Sans Mono';
  {$ENDIF}
  fFont.Quality := fqProof;
  fFont.Pitch := fpFixed;
  fFont.Size := 10;
  fResetFontSize:=true;
  //
  fD2Syn := TSynD2Syn.Create(self);
  fD2Syn.Assign(D2Syn);
  fTxtSyn := TSynTxtSyn.Create(self);
  fTxtSyn.Assign(TxtSyn);
  //
  fDDocDelay:=200;
  fAutoDotDelay:=100;
  fCurrLineAttribs := TSynSelectedColor.Create;
  fSelAttribs := TSynSelectedColor.Create;
  fFoldedColor := TSynSelectedColor.Create;
  fMouseLinkAttribs := TSynSelectedColor.Create;
  fBracketMatchAttribs := TSynSelectedColor.Create;
  fIdentifierMarkup := TSynSelectedColor.Create;
  fCompletionMenuCaseCare := true;
  //
  // note: default values come from TSynEditFoldedView ctor.
  fFoldedColor.Background := clNone;
  fFoldedColor.Foreground := clDkGray;
  fFoldedColor.FrameColor := clDkGray;
  //
  fSelAttribs.Background := 13421772;
  fSelAttribs.Foreground := clNone;
  //
  fMouseLinkAttribs.Style := [fsUnderline, fsBold];
  fMouseLinkAttribs.StyleMask := [];
  fMouseLinkAttribs.Foreground := clNone;
  fMouseLinkAttribs.Background := clNone;
  //
  fBracketMatchAttribs.Foreground := clRed;
  fBracketMatchAttribs.Background := clNone;
  //
  fIdentifierMarkup.Foreground:= clNone;
  fIdentifierMarkup.Background:= clSilver;
  fIdentifierMarkup.BackAlpha:=70;
  fIdentiMatchOpts := [caseSensitive];
  //
  fAutoCloseCurlyBrace:= autoCloseOnNewLineLexically;
  fAutoClosedPairs:= [];
  //
  fCompletionMenuWidth:= 320;
  fCompletionMenuLines:= 15;
  //
  fLineNumEvery := 5;
  rightEdge := 80;
  tabulationWidth := 4;
  blockIndentation := 4;
  fBackground := clWhite;
  fRightEdgeColor := clSilver;
  fSmartDdocNewline:=true;
  fScrollPreview:=true;
  //
  fDscannerEnabled:=true;
  fDscannerDelay:= 2200;
  //
  fCurrLineAttribs.Background := 15789545;
  fCurrLineAttribs.Foreground := clNone;
  //
  fCloseCompletionCharsWithSpace := '*+-/^=~><%';
  fCloseCompletionChars:= '.,;)}]!';
  //
  options1 :=
    [eoAutoIndent, eoBracketHighlight, eoGroupUndo, eoTabsToSpaces, eoTrimTrailingSpaces,
    eoDragDropEditing, eoShowCtrlMouseLinks, eoEnhanceHomeKey, eoTabIndent];
  options2 :=
    [eoEnhanceEndKey, eoFoldedCopyPaste, eoOverwriteBlock];
  //
  mouseOptions := MouseOptions +
    [emAltSetsColumnMode, emDragDropEditing, emCtrlWheelZoom, emShowCtrlMouseLinks];
  //
  fShortCuts := TCollection.Create(TCEPersistentShortcut);
  ed := TSynEdit.Create(nil);
  try
    // note: cant use a TCESynMemo because it'd be added to the EntitiesConnector
    SetDefaultCoeditKeystrokes(ed);
    for i:= 0 to ed.Keystrokes.Count-1 do
    begin
      shc := TCEPersistentShortcut(fShortCuts.Add);
      shc.actionName:= EditorCommandToCodeString(ed.Keystrokes[i].Command);
      shc.shortcut  := ed.Keystrokes[i].ShortCut;
    end;
  finally
    ed.free;
  end;
end;

destructor TCEEditorOptionsBase.Destroy;
begin
  fFont.Free;
  fCurrLineAttribs.Free;
  fSelAttribs.Free;
  fShortCuts.Free;
  fFoldedColor.Free;
  fMouseLinkAttribs.Free;
  fBracketMatchAttribs.Free;
  fIdentifierMarkup.Free;
  inherited;
end;

procedure TCEEditorOptionsBase.Assign(source: TPersistent);
var
  srcopt: TCEEditorOptionsBase;
begin
  if (source is TCEEditorOptionsBase) then
  begin
    srcopt := TCEEditorOptionsBase(source);
    //
    fDscannerDelay:=srcopt.fDscannerDelay;
    fDscannerEnabled:=srcopt.dscannerEnabled;
    fTransparentGutter:=srcopt.fTransparentGutter;
    fAlwaysAdvancedFeatures:=srcopt.fAlwaysAdvancedFeatures;
    fResetFontSize:=srcopt.fResetFontSize;
    fAutoCloseCurlyBrace := srcopt.fAutoCloseCurlyBrace;
    fAutoClosedPairs := srcopt.fAutoClosedPairs;
    fCompletionMenuWidth:=srcopt.fCompletionMenuWidth;
    fCompletionMenuLines:=srcopt.fCompletionMenuLines;
    fCompletionMenuCaseCare:=srcopt.fCompletionMenuCaseCare;
    fCompletionMenuAutoClose:= srcopt.fCompletionMenuAutoClose;
    fAutoDotDelay:=srcopt.fAutoDotDelay;
    fDDocDelay:=srcopt.fDDocDelay;
    fFont.Assign(srcopt.fFont);
    fSelAttribs.Assign(srcopt.fSelAttribs);
    fFoldedColor.Assign(srcopt.fFoldedColor);
    fMouseLinkAttribs.Assign(srcopt.fMouseLinkAttribs);
    fBracketMatchAttribs.Assign(srcopt.fBracketMatchAttribs);
    fCurrLineAttribs.Assign(srcopt.fCurrLineAttribs);
    fD2Syn.Assign(srcopt.fD2Syn);
    fTxtSyn.Assign(srcopt.fTxtSyn);
    background := srcopt.background;
    lineNumberEvery := srcopt.lineNumberEvery;
    identifierMatchOptions:=srcopt.identifierMatchOptions;
    detectIndentMode:=srcopt.detectIndentMode;
    fPhobosDocRoot:=srcopt.fPhobosDocRoot;
    fInsertPlusDdoc:= srcopt.fInsertPlusDdoc;
    fAutoCallCompletion:= srcopt.fAutoCallCompletion;
    fCloseCompletionChars:=srcopt.fCloseCompletionChars;
    fCloseCompletionCharsWithSpace:=srcopt.fCloseCompletionCharsWithSpace;
    fScrollPreview:=srcopt.fScrollPreview;

    fSmartDdocNewline:=srcopt.fSmartDdocNewline;
    if fSmartDdocNewline then
      fOptions1 += [eoAutoIndent];

    tabulationWidth := srcopt.tabulationWidth;
    blockIndentation := srcopt.blockIndentation;
    lineSpacing := srcopt.lineSpacing;
    characterSpacing := srcopt.characterSpacing;
    options1 := srcopt.options1;
    options2 := srcopt.options2;
    mouseOptions := srcopt.mouseOptions;
    rightEdge := srcopt.rightEdge;
    rightEdgeColor := srcopt.rightEdgeColor;
    fShortCuts.Assign(srcopt.fShortCuts);
  end
  else
    inherited;
end;

procedure TCEEditorOptionsBase.setDDocDelay(value: Integer);
begin
  if value > 2000 then value := 2000
  else if value < 20 then value := 20;
  fDDocDelay:=value;
end;

procedure TCEEditorOptionsBase.setDscannerDelay(value: Integer);
begin
  if value > 10000 then value := 10000
  else if value < 500 then value := 500;
  fDscannerDelay:=value;
end;

procedure TCEEditorOptionsBase.setAutoDotDelay(value: Integer);
begin
  if value > 2000 then value := 2000
  else if value < 0 then value := 0;
  fAutoDotDelay:=value;
end;

procedure TCEEditorOptionsBase.setCompletionMenuLines(value: byte);
begin
  if value < 5 then value := 5
  else if value > 64 then value := 64;
  fCompletionMenuLines := value;
end;

procedure TCEEditorOptionsBase.setLineNumEvery(value: integer);
begin
  if value < 1 then value := 1
  else if value > 10 then value := 10;
  fLineNumEvery := value;
end;

procedure TCEEditorOptionsBase.setShortcuts(value: TCollection);
begin
  fShortCuts.Assign(value);
end;

procedure TCEEditorOptionsBase.setFont(value: TFont);
begin
  fFont.Assign(value);
end;

procedure TCEEditorOptionsBase.setPhobosDocRoot(value: TCEPathname);
begin
  if not DirectoryExists(value)  and (value <> 'https://dlang.org/phobos/') then
    value := 'https://dlang.org/phobos/';
  if (value[length(value)] <> DirectorySeparator) and DirectoryExists(value) then
    value += DirectorySeparator;
  fPhobosDocRoot:=value;
end;

procedure TCEEditorOptionsBase.setSelCol(value: TSynSelectedColor);
begin
  fSelAttribs.Assign(value);
end;

procedure TCEEditorOptionsBase.setFoldedColor(value: TSynSelectedColor);
begin
  fFoldedColor.Assign(value);
end;

procedure TCEEditorOptionsBase.setMouseLinkColor(value: TSynSelectedColor);
begin
  fMouseLinkAttribs.Assign(value);
end;

procedure TCEEditorOptionsBase.setBracketMatchColor(value: TSynSelectedColor);
begin
  fBracketMatchAttribs.Assign(value);
end;

procedure TCEEditorOptionsBase.SetIdentifierMarkup(value: TSynSelectedColor);
begin
  fIdentifierMarkup.Assign(value);
end;

procedure TCEEditorOptionsBase.setCurrLineAttribs(value: TSynSelectedColor);
begin
  fCurrLineAttribs.Assign(value);
end;

procedure TCEEditorOptionsBase.setD2Syn(value: TPersistent);
begin
  D2Syn.Assign(value);
end;

procedure TCEEditorOptionsBase.setTxtSyn(value: TPersistent);
begin
  TxtSyn.Assign(value);
end;

constructor TCEEditorOptions.Create(AOwner: TComponent);
var
  fname: string;
begin
  inherited;
  fBackup := TCEEditorOptionsBase.Create(self);
  EntitiesConnector.addObserver(self);
  //
  fname := getCoeditDocPath + edoptFname;
  if fileExists(fname) then
    loadFromFile(fname);
end;

destructor TCEEditorOptions.Destroy;
begin
  saveToFile(getCoeditDocPath + edoptFname);
  //
  EntitiesConnector.removeObserver(self);
  inherited;
end;

procedure TCEEditorOptions.afterLoad;
var
  ed: TSynEdit;
  shc: TCEPersistentShortcut;
  i,j: integer;
  exists: boolean;
begin
  inherited;
  D2Syn.Assign(fD2Syn);
  TxtSyn.Assign(fTxtSyn);
  //
  ed := TSynEdit.Create(nil);
  try
    SetDefaultCoeditKeystrokes(ed);
    // new version with more shortcuts
    for i:= 0 to ed.Keystrokes.Count-1 do
    begin
      exists := false;
      for j := 0 to fShortcuts.count-1 do
      begin
        if TCEPersistentShortcut(fShortCuts.Items[j]).actionName <>
          EditorCommandToCodeString(ed.Keystrokes.Items[i].Command) then
            continue;
        exists := true;
        break;
      end;
      if exists then
        continue;
      shc := TCEPersistentShortcut(fShortCuts.Add);
      shc.actionName := EditorCommandToCodeString(ed.Keystrokes.Items[i].Command);
      shc.shortcut := ed.Keystrokes.Items[i].ShortCut;
    end;
    // new version wih less shortcuts
    for j := fShortcuts.count-1 downto 0 do
    begin
      exists := false;
      for i:= 0 to ed.Keystrokes.Count-1 do
      begin
        if TCEPersistentShortcut(fShortCuts.Items[j]).actionName <>
          EditorCommandToCodeString(ed.Keystrokes.Items[i].Command) then
            continue;
        exists := true;
        break;
      end;
      if exists then
        continue;
      fShortCuts.Delete(j);
    end;
  finally
    ed.free;
  end;
end;
{$ENDREGION}

{$REGION ICEDocumentObserver ---------------------------------------------------}
procedure TCEEditorOptions.docNew(document: TCESynMemo);
begin
  //apply...des not modify font size to preserve current zoom
  // when called after the options are edited
  applyChangeToEditor(document);
  // must be set manually for a new doc
  document.Font.Size:=self.font.Size;
end;

procedure TCEEditorOptions.docFocused(document: TCESynMemo);
begin
end;

procedure TCEEditorOptions.docChanged(document: TCESynMemo);
begin
end;

procedure TCEEditorOptions.docClosing(document: TCESynMemo);
begin
  fCompletionMenuWidth := document.completionMenu.TheForm.Width;
  fCompletionMenuLines := document.completionMenu.LinesInWindow;
end;
{$ENDREGION}

{$REGION ICEEDitableShortcut ---------------------------------------------------}
function TCEEditorOptions.scedWantFirst: boolean;
begin
  result := fShortCuts.Count > 0;
  fShortcutCount := 0;
end;

function TCEEditorOptions.scedWantNext(out category, identifier: string; out aShortcut: TShortcut): boolean;
var
  shrct: TCEPersistentShortcut;
begin
  shrct     := TCEPersistentShortcut(fShortCuts.Items[fShortcutCount]);
  category  := 'Code editor';
  identifier:= shrct.actionName;
  // SynEdit shortcuts start with 'ec'
  if identifier.length > 2 then
    identifier := identifier[3..identifier.length];
  aShortcut := shrct.shortcut;
  //
  fShortcutCount += 1;
  result := fShortcutCount < fShortCuts.Count;
end;

procedure TCEEditorOptions.scedSendItem(const category, identifier: string; aShortcut: TShortcut);
var
  i: Integer;
  shc: TCEPersistentShortcut;
begin
  if category <> 'Code editor' then exit;
  //
  for i:= 0 to fShortCuts.Count-1 do
  begin
    shc := TCEPersistentShortcut(fShortCuts.Items[i]);
    if shc.actionName.length > 2 then
    begin
      if shc.actionName[3..shc.actionName.length] <> identifier then
        continue;
    end else if shc.actionName <> identifier then
      continue;
    shc.shortcut:= aShortcut;
    break;
  end;
  // note: shortcut modifications are not reversible,
  // they are sent from another option editor.
end;

procedure TCEEditorOptions.scedSendDone;
begin
  applyChangesFromSelf;
end;

{$ENDREGION}

{$REGION ICEEditableOptions ----------------------------------------------------}
function TCEEditorOptions.optionedWantCategory(): string;
begin
  exit('Editor');
end;

function TCEEditorOptions.optionedWantEditorKind: TOptionEditorKind;
begin
  exit(oekGeneric);
end;

function TCEEditorOptions.optionedWantContainer: TPersistent;
begin
  fD2Syn := D2Syn;
  fTxtSyn := TxtSyn;
  fBackup.Assign(self);
  fBackup.fD2Syn.Assign(D2Syn);
  fBackup.fTxtSyn.Assign(TxtSyn);
  exit(self);
end;

procedure TCEEditorOptions.optionedEvent(event: TOptionEditorEvent);
begin
  // restores
  if event = oeeCancel then
  begin
    self.Assign(fBackup);
    D2Syn.Assign(fBackup.fD2Syn);
    TxtSyn.Assign(fBackup.fTxtSyn);
  end;
  // apply, if change/accept event
  // to get a live preview
  if event <> oeeSelectCat then
    applyChangesFromSelf;
  // new backup values based on accepted values.
  if event = oeeAccept then
  begin
    fBackup.Assign(self);
    fBackup.fD2Syn.Assign(D2Syn);
    fBackup.fTxtSyn.Assign(TxtSyn);
  end;
end;

function TCEEditorOptions.optionedOptionsModified: boolean;
begin
  exit(false);
end;
{$ENDREGION}

{$REGION ICEEditableOptions ----------------------------------------------------}
procedure TCEEditorOptions.applyChangesFromSelf;
var
  multied: ICEMultiDocHandler;
  i: Integer;
begin
  multied := getMultiDocHandler;
  for i := 0 to multied.documentCount - 1 do
    applyChangeToEditor(multied.document[i]);
end;

procedure TCEEditorOptions.applyChangeToEditor(anEditor: TCESynMemo);
var
  i, j: Integer;
  shc: TCEPersistentShortcut;
  kst: TSynEditKeyStroke;
  dup: boolean;
  savedSize: integer;
  cs: TSysCharSet;
  c: char;
begin
  anEditor.D2Highlighter.Assign(D2Syn);
  anEditor.TxtHighlighter.Assign(TxtSyn);

  anEditor.autoDotDelay:=fAutoDotDelay;
  anEditor.ddocDelay:=fDDocDelay;

  savedSize := anEditor.Font.Size;
  anEditor.defaultFontSize := font.Size;
  anEditor.Font.Assign(font);
  if not fResetFontSize then
    anEditor.Font.Size := savedSize;

  anEditor.completionMenu.TheForm.Font.Assign(font);
  anEditor.autoCloseCurlyBrace            := fAutoCloseCurlyBrace;
  anEditor.autoClosedPairs                := fAutoClosedPairs;
  anEditor.completionMenu.TheForm.Width   := fCompletionMenuWidth;
  anEditor.completionMenu.LinesInWindow   := fCompletionMenuLines;
  anEditor.completionMenu.CaseSensitive   := fCompletionMenuCaseCare;
  TStringList(anEditor.completionMenu.ItemList).CaseSensitive := fCompletionMenuCaseCare;

  anEditor.Gutter.LineNumberPart.ShowOnlyLineNumbersMultiplesOf:=fLineNumEvery;

  anEditor.SelectedColor.Assign(fSelAttribs);
  anEditor.FoldedCodeColor.Assign(fFoldedColor);
  anEditor.MouseLinkColor.Assign(fMouseLinkAttribs);
  anEditor.BracketMatchColor.Assign(fBracketMatchAttribs);
  anEditor.HighlightAllColor.Assign(fIdentifierMarkup);
  anEditor.LineHighlightColor.Assign(fCurrLineAttribs);
  anEditor.TabWidth := tabulationWidth;
  anEditor.ExtraLineSpacing := lineSpacing;
  anEditor.ExtraCharSpacing := characterSpacing;
  anEditor.Options := options1;
  anEditor.Options2 := options2;
  anEditor.MouseOptions := mouseOptions;
  anEditor.Color := background;
  anEditor.RightEdge := rightEdge;
  anEditor.RightEdgeColor := rightEdgeColor;
  anEditor.IdentifierMatchOptions:= identifierMatchOptions;
  anEditor.detectIndentMode := detectIndentMode;
  anEditor.phobosDocRoot:=fPhobosDocRoot;
  anEditor.alwaysAdvancedFeatures:=fAlwaysAdvancedFeatures;
  anEditor.smartDdocNewline:= fSmartDdocNewline;
  anEditor.insertPlusDdoc:= fInsertPlusDdoc;
  anEditor.autoCallCompletion:= fAutoCallCompletion;
  anEditor.completionMenuAutoClose:=fCompletionMenuAutoClose;
  anEditor.transparentGutter:=fTransparentGutter;
  anEditor.setDscannerOptions(fDscannerEnabled, fDscannerDelay);
  anEditor.scrollPreview:=fScrollPreview;

  if not (eoTabsToSpaces in options1) then
  begin
    anEditor.BlockIndent := 0;
    anEditor.BlockTabIndent := 1;
  end
  else
  begin
    anEditor.BlockIndent := blockIndentation;
    anEditor.BlockTabIndent := 0;
  end;

  cs := [];
  for c in fCloseCompletionCharsWithSpace do
    include(cs, c);
  anEditor.closeCompletionCharsWithSpace:=cs;

  cs := [];
  for c in fCloseCompletionChars do
    include(cs, c);
  anEditor.closeCompletionChars:=cs;

  for i := 0 to anEditor.Keystrokes.Count-1 do
  begin
    kst := anEditor.Keystrokes.Items[i];
    kst.ShortCut:= 0;
    kst.ShortCut2:= 0;
  end;

  for i := 0 to anEditor.Keystrokes.Count-1 do
  begin
    kst := anEditor.Keystrokes.Items[i];
    for j := 0 to fShortCuts.Count-1 do
    begin
      dup := false;
      shc := TCEPersistentShortcut(fShortCuts.Items[j]);
      if shc.actionName = EditorCommandToCodeString(kst.Command) then
      begin
        if not dup then
        try
          kst.shortCut := shc.shortcut;
        except
          kst.shortCut := 0;
        end;
        break;
      end;
    end;
  end;
end;
{$ENDREGION}

initialization
  EditorOptions := TCEEditorOptions.Create(nil);

finalization
  EditorOptions.Free;
end.
