unit ce_interfaces;

{$I ce_defines.inc}

interface

uses
  Classes, SysUtils, actnList, menus, process,
  ce_synmemo, ce_observer;

type

  // describes the project kind. Used as a hint to cast ICECommonProject.getProject()
  TCEProjectFormat = (pfDEXED, pfDUB);

  // describes the binary kind produces when compiling a project
  TProjectBinaryKind = (executable, staticlib, sharedlib, obj);

  (**
   * Common project interface.
   *
   * Each project format has its own dedicated editors.
   * A few common properties allow some generic operations whatever is the format.
   *)
  ICECommonProject = interface
  ['ICECommonProject']

    // general properties ------------------------------------------------------

      // indicates if the project is owned by a group.
      function inGroup: boolean;
      // flag the project as grouped
      procedure inGroup(value: boolean);
      // in a context of a group, activates the project
      procedure activate;
      // indicates the project format
      function getFormat: TCEProjectFormat;
      // returns an untyped object that can be casted using getFormat()
      function getProject: TObject;
      // returns the project filename
      function filename: string;
      // loads project from filename
      procedure loadFromFile(const fname: string);
      // saves project to filename
      procedure saveToFile(const fname: string);
      // reloads from filename
      procedure reload;
      // indicates of the project is modified (should be saved or not)
      function modified: boolean;
      // returns the base path used to solve relative locations
      function basePath: string;
      // returns the name of the file produced when a project is compiled
      function outputFilename: string;
      // returns the binary kind produced according to the current configuration
      function binaryKind: TProjectBinaryKind;
      // returns what's gonna be executed in background for this config
      function getCommandLine: string;
      // stops compilation
      procedure stopCompilation;

    // configs -----------------------------------------------------------------

      // returns the count of configuration
      function configurationCount: integer;
      // sets the active configuration
      procedure setActiveConfigurationIndex(index: integer);
      // returns the name of the index-th configuration
      function configurationName(index: integer): string;
      // return the index of the active configration index
      function getActiveConfigurationIndex: integer;

    // project sources ---------------------------------------------------------

      // returns the count of source files for the current config
      function sourcesCount: integer;
      // returns the source absolute filename.
      function sourceAbsolute(index: integer): string;
      // returns the source relative filename.
      function sourceRelative(index: integer): string;
      // returns true if aFilename is a project source.
      function isSource(const aFilename: string): boolean;
      // returns the count of import paths for the current config
      function importsPathCount: integer;
      // returns the import absolute path
      function importPath(index: integer): string;

    // sub routines for the actions --------------------------------------------

      // tries to compile.
      procedure compile;
      // indicates wether last complation was successful.
      function compiled: boolean;
      // tries to execute the project output.
      procedure run(const runArgs: string = '');
      // test the project (only for DUB)
      procedure test;
      // returns true if the target has not to be recompiled
      function targetUpToDate: boolean;

  end;



  (**
   * An implementer declares some actions on demand.
   *)
  ICEContextualActions = interface(IObserverType)
  ['ICEContextualActions']
    // declares a context name for the actions
    function contextName: string;
    // action count, called before contextAction()
    function contextActionCount: integer;
    // declares actions, called in loop, from 0 to contextActionCount-1
    function contextAction(index: integer): TAction;
  end;



  (**
   * An implementer is informed about the current file(s).
   *)
  ICEDocumentObserver = interface(IObserverType)
  ['ICEDocumentObserver']
    // document has been created (empty, runnable, project source, ...).
    procedure docNew(document: TCESynMemo);
    // document is the document being edited.
    procedure docFocused(document: TCESynMemo);
    // document content has just been modified (edited, saved).
    procedure docChanged(document: TCESynMemo);
    // document is about to be closed.
    procedure docClosing(document: TCESynMemo);
  end;
  (**
   * An implementer informs the ICEMultiDocObserver about the current file(s)
   *)
  TCEMultiDocSubject = specialize TCECustomSubject<ICEDocumentObserver>;



  (**
   * An implementer is informed about the current project(s).
   * Usually observer should keep track of two ICECommonProject:
   * - the "free standing project" (FSP): the project that's not in a group and
   * that has to be freed manualy in order to be replaced.
   * - the current project, the one that's active) which can be either the FSP
   * or one of the project in the group.
   *)
  ICEProjectObserver = interface(IObserverType)
  ['ICEProjectObserver']
    // a project has been created/opened
    procedure projNew(project: ICECommonProject);
    // a project has been modified: switches, source name, ...
    procedure projChanged(project: ICECommonProject);
    // a project is about to be closed.
    procedure projClosing(project: ICECommonProject);
    // a project is focused, it can be inGroup or not
    procedure projFocused(project: ICECommonProject);
    // project is about to be compiled, time to lock related actions.
    procedure projCompiling(project: ICECommonProject);
    // project compilation is finsihed, related actions can be unlocked.
    procedure projCompiled(project: ICECommonProject; success: boolean);
  end;
  (**
   * An implementer informs the ICEProjectObserver about the current project(s)
   *)
  TCEProjectSubject = specialize TCECustomSubject<ICEProjectObserver>;



  (**
   * An implementer can expose customizable shortcuts to be edited in a dedicated widget.
   *)
  ICEEditableShortCut = interface(IObserverType)
  ['ICEEditableShortCut']
    // a TCEEditableShortCutSubject will start to collect shortcuts if result.
    function scedWantFirst: boolean;
    // a TCEEditableShortCutSubject collects the information on the shortcuts while result.
    function scedWantNext(out category, identifier: string; out aShortcut: TShortcut): boolean;
    // a TCEEditableShortCutSubject sends the possibly modified shortcut.
    procedure scedSendItem(const category, identifier: string; aShortcut: TShortcut);
    // a TCEEditableShortCutSubject has finished to send the shortcuts.
    procedure scedSendDone;
  end;
  (**
   * An implementer manages its observers shortcuts.
   *)
  TCEEditableShortCutSubject = specialize TCECustomSubject<ICEEditableShortCut>;

  (**
   * Listen to mini explorer changes. Mostly made to prevent redundant updates
   * of the symbolic string translater.
   *)
  ICEMiniExplorerObserver = interface(IObserverType)
  ['ICEMiniExplorerObserver']
    procedure mnexDirectoryChanged(const directory: string);
  end;
  (**
   * Mini-explorer implements this.
   *)
  TCEMiniExplorerSubject = specialize TCECustomSubject<ICEMiniExplorerObserver>;


  // the option editor uses this value as a hint to display an option container.
  TOptionEditorKind = (
    oekGeneric, // the editor will display the publications of the TPersistent passed in optionedWantContainer
    oekForm,    // the editor will cast the result of optionedWantContainer as a TForm and host this form
    oekControl  // the editor will cast the result of optionedWantContainer as a TControl and host this control
  );
  // event generated by the option editor and passed to an ICEEditableOptions.
  TOptionEditorEvent = (
    oeeCancel,    // the "cancel" button of the option editor is pressed
    oeeAccept,    // the "accept" button of the option editor is pressed
    oeeChange,    // the properties of the container has changed, only happens if the container is oekGeneric.
    oeeSelectCat  // the container will be displayed.
  );
  (**
   * An implementer can expose options to be edited in a dedicated widget.
   *)
  ICEEditableOptions = interface(IObserverType)
  ['ICEEditableOptions']
    // the widget wants the category.
    function optionedWantCategory(): string;
    // the widget wants to know if the options will use a generic editor or a custom form.
    function optionedWantEditorKind: TOptionEditorKind;
    // the widget wants the custom option editor TCustomForm, TWinControl or the TPersistent containing the options.
    function optionedWantContainer: TPersistent;
    // the option editor informs that something has happened.
    procedure optionedEvent(event: TOptionEditorEvent);
    // the option editor wants to know if an editor allows another category to be displayed (not called for oekGeneric).
    function optionedOptionsModified: boolean;
  end;
  (**
   * An implementer displays its observers editable options.
   *)
  TCEEditableOptionsSubject = specialize TCECustomSubject<ICEEditableOptions>;



  /// describes the message kind, 'amkAuto' implies that an ICELogMessageObserver guess the kind.
  TCEAppMessageKind = (amkAuto, amkBub, amkInf, amkHint, amkWarn, amkErr);
  /// describes the message context. Used by a ICELogMessageObserver to filter the messages.
  TCEAppMessageCtxt = (
    amcAll,         // used as filter
    amcEdit,        // used as filter
    amcProj,        // used as filter
    amcApp,         // used as filter
    amcMisc,        // used as filter
    amcAutoEdit,    // same as amcEdit but the message data is set automatically by the ICEMessagesDisplay
    amcAutoProj,    // same as amcProj but the message data is set automatically by the ICEMessagesDisplay
    amcAutoCompile  // same as amcAutoEdit or amcAutoProj but set by the ICEMessagesDisplay according to what's being compiled.
  );

  TLifetimeStatus = (
    lfsLoading,  // IDE is not ready yet, other services might be nil
    lfsLoaded,   // IDE is 100% working
    lfsExiting  // IDE is quiting, other services will be nil
  );

  (**
   * Single service providing information about the IDE liftetime
   *)
  ICELifetimeManager = interface(ICESingleService)
    function getLifetimeStatus: TLifetimeStatus;
    function asObject: TObject;
  end;

  (**
   * Single service provided by the messages widget.
   *)
  ICEMessagesDisplay = interface(ICESingleService)
    // displays a message.
    procedure message(const value: string; aData: Pointer; aCtxt: TCEAppMessageCtxt; aKind: TCEAppMessageKind);
    // clears the messages related to the context aCtxt.
    procedure clearByContext(aCtxt: TCEAppMessageCtxt);
    // clears the messages related to the data aData.
    procedure clearByData(aData: Pointer);
  end;



  (**
   * Single service provided by the process-input widget.
   *)
  ICEProcInputHandler = interface(ICESingleService)
    // add an entry to the list of process which can receive an user input.
    procedure addProcess(aProcess: TProcess);
    // removes an entry.
    procedure removeProcess(aProcess: TProcess);
    // indicates the current process.
    function process: TProcess;
  end;



  (**
   * Single service related to the documents as a collection.
   *)
  ICEMultiDocHandler = interface(ICESingleService)
    // returns the count of opened document.
    function documentCount: Integer;
    // returns the nth document.
    function getDocument(index: Integer): TCESynMemo;
    // returns true if the document matching aFilename is already opened.
    function findDocument(const fname: string): TCESynMemo;
    // opens or set the focus on the document matching aFilename.
    procedure openDocument(const fname: string);
    // closes the nth document.
    function closeDocument(index: Integer; promptOnChanged: boolean = true): boolean;
    // closes a particular document.
    function closeDocument(doc: TCESynMemo; promptOnChanged: boolean = true): boolean;
    // conveniance property.
    property document[index: integer]: TCESynMemo read getDocument;
  end;



  (**
   * Single service related to the project groups
   *)
  ICEProjectGroup = interface(ICESingleService)
    // adds a project to the gtoup.
    procedure addProject(project: ICECommonProject);
    // opens a group of project.
    procedure openGroup(const fname: string);
    // saves the group to a file.
    procedure saveGroup(const fname: string);
    // closes a group and initialize a new one.
    procedure closeGroup;
    // indicates wether one of the project is modified or if the group is changed.
    function groupModified: boolean;
    // indicates the group filename.
    function groupFilename: string;
    // indicates the count of project in the group.
    function projectCount: integer;
    // indicates the index of the project.
    function getProjectIndex: integer;
    // returns the nth project.
    function getProject(index: Integer): ICECommonProject;
    // returns true if the nth project is modified
    function projectModified(index: integer): boolean;
    // tries to find the project named fname.
    function findProject(const fname: string): ICECommonProject;
    // selects the nth project of the group.
    procedure setProjectIndex(index: Integer);
    // indicates wether a project is marked for async compilation
    function projectIsAsync(index: integer): boolean;
    // indicates the project index after reloading
    function reloadedProjectIndex: integer;
  end;



  (**
   * Single service related to the expansion of "symbolic strings".
   *)
  ICESymStringExpander = interface(ICESingleService)
    // expands all the symbols <IDENT> of value in result.
    function expand(const value: string): string;
  end;


  (**
   * Single service related to build-in file explorer.
   *)
  ICEExplorer = interface(ICESingleService)
    // expands the explorer to the folder "location".
    procedure browse(const location: string);
    // returns current folder.
    function currentLocation: string;
  end;


  (**
   * Single service provided by the options editor.
   *)
  ICEOptionsEditor = interface(ICESingleService)
    // Shows the editor. When observer is not nil, its category is selected.
    procedure showOptionEditor(observer: ICEEditableOptions = nil);
  end;


  DCompiler = (dmd, gdc, gdmd, ldc, ldmd, user1, user2);

  (**
   * Single service provided by the options editor.
   *)
  ICECompilerSelector = interface(ICESingleService)
    // Indicates wether a D compiler is usable.
    function isCompilerValid(value: DCompiler): boolean;
    // Returns a D compiler exe filename.
    function getCompilerPath(value: DCompiler): string;
    // Fills value with the runtime/phobos import paths for a particular D compiler.
    procedure getCompilerImports(value: DCompiler; paths: TStrings);
  end;

  // Returns a string indicating the which compiler will be used.
  function usingCompilerInfo(value: DCompiler): string;

type

  (**
   * Single service that provides access to the main menu.
   *)
  ICEMainMenu = interface(ICESingleService)
    // adds a main menu entry
    function mnuAdd: TMenuItem;
    // removes a main menu entry
    procedure mnuDelete(value: TMenuItem);
  end;



  (**
   * Single service for DFMT
   *)
  ICECodeFormatting = interface(ICESingleService)
    // formats the focused editor
    procedure formatCurrent();
  end;


  TDCDCompletionKind = (
    dckClass,
    dckInterface,
    dckStruct,
    dckUnion,
    dckVariable,
    dckMember,
    dckReserved,
    dckFunction,
    dckEnum,
    dckEnum_member,
    dckPackage,
    dckModule,
    dckArray,
    dckAA,
    dckAlias,
    dckTemplate,
    dckMixin
  );



{
  subject primitives:

  A subject cannot necessarly provides all the informations the observers expect.
  It can compose using the following "primitives".
}

  (**
   * TCEMultiDocSubject primitives.
   *)
  procedure subjDocNew(aSubject: TCEMultiDocSubject; document: TCESynMemo);      {$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjDocClosing(aSubject: TCEMultiDocSubject; document: TCESynMemo);  {$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjDocFocused(aSubject: TCEMultiDocSubject; document: TCESynMemo);  {$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjDocChanged(aSubject: TCEMultiDocSubject; document: TCESynMemo);  {$IFDEF RELEASE}inline;{$ENDIF}

  (**
   * TCEProjectSubject primitives.
   *)
  procedure subjProjNew(aSubject: TCEProjectSubject; project: ICECommonProject);     {$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjProjClosing(aSubject: TCEProjectSubject; project: ICECommonProject); {$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjProjFocused(aSubject: TCEProjectSubject; project: ICECommonProject); {$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjProjChanged(aSubject: TCEProjectSubject; project: ICECommonProject); {$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjProjCompiling(aSubject: TCEProjectSubject; project: ICECommonProject);{$IFDEF RELEASE}inline;{$ENDIF}
  procedure subjProjCompiled(aSubject: TCEProjectSubject; project: ICECommonProject; success: boolean);{$IFDEF RELEASE}inline;{$ENDIF}

  (**
   * TCEMiniExplorerSubject primitives.
   *)
  procedure subjMnexDirectoryChanged(aSubject: TCEMiniExplorerSubject; const directory: string); {$IFDEF RELEASE}inline;{$ENDIF}


{
  Service getters:
}
  function getMessageDisplay(var obj: ICEMessagesDisplay): ICEMessagesDisplay; inline;
  function getMessageDisplay: ICEMessagesDisplay; inline;
  function getprocInputHandler: ICEProcInputHandler; inline;
  function getMultiDocHandler: ICEMultiDocHandler; inline;
  function getSymStringExpander: ICESymStringExpander; inline;
  function getProjectGroup: ICEProjectGroup; inline;
  function getExplorer: ICEExplorer; inline;
  function getOptionsEditor: ICEOptionsEditor; inline;
  function getCompilerSelector: ICECompilerSelector; inline;
  function getMainMenu: ICEMainMenu; inline;
  function getCodeFormatting: ICECodeFormatting; inline;
  function getLifeTimeManager: ICELifetimeManager; inline;

implementation

{$REGION TCEMultiDocSubject ----------------------------------------------------}
procedure subjDocNew(aSubject: TCEMultiDocSubject; document: TCESynMemo);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEDocumentObserver).docNew(document);
end;

procedure subjDocClosing(aSubject: TCEMultiDocSubject; document: TCESynMemo);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEDocumentObserver).docClosing(document);
end;

procedure subjDocFocused(aSubject: TCEMultiDocSubject; document: TCESynMemo);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEDocumentObserver).docFocused(document);
end;

procedure subjDocChanged(aSubject: TCEMultiDocSubject; document: TCESynMemo);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEDocumentObserver).docChanged(document);
end;
{$ENDREGION}

{$REGION TCEMiniExplorerSubject ------------------------------------------------}
procedure subjMnexDirectoryChanged(aSubject: TCEMiniExplorerSubject; const directory: string);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEMiniExplorerObserver).mnexDirectoryChanged(directory);
end;
{$ENDREGION}

{$REGION TCEProjectSubject -----------------------------------------------------}
procedure subjProjNew(aSubject: TCEProjectSubject; project: ICECommonProject);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEProjectObserver).ProjNew(project);
end;

procedure subjProjClosing(aSubject: TCEProjectSubject; project: ICECommonProject);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEProjectObserver).projClosing(project);
end;

procedure subjProjFocused(aSubject: TCEProjectSubject; project: ICECommonProject);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEProjectObserver).projFocused(project);
end;

procedure subjProjChanged(aSubject: TCEProjectSubject; project: ICECommonProject);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEProjectObserver).projChanged(project);
end;

procedure subjProjCompiling(aSubject: TCEProjectSubject; project: ICECommonProject);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEProjectObserver).projCompiling(project);
end;

procedure subjProjCompiled(aSubject: TCEProjectSubject; project: ICECommonProject; success: boolean);
var
  i: Integer;
begin
  with aSubject do for i:= 0 to fObservers.Count-1 do
    (fObservers[i] as ICEProjectObserver).projCompiled(project, success);
end;
{$ENDREGION}

{$REGION ICESingleService getters ----------------------------------------------}
function getMessageDisplay(var obj: ICEMessagesDisplay): ICEMessagesDisplay;
begin
  if obj = nil then
    obj := EntitiesConnector.getSingleService('ICEMessagesDisplay') as ICEMessagesDisplay;
  exit(obj);
end;

function getMessageDisplay: ICEMessagesDisplay;
begin
  exit(EntitiesConnector.getSingleService('ICEMessagesDisplay') as ICEMessagesDisplay);
end;

function getprocInputHandler(var obj: ICEProcInputHandler): ICEProcInputHandler;
begin
  if obj = nil then
    obj := EntitiesConnector.getSingleService('ICEProcInputHandler') as ICEProcInputHandler;
  exit(obj);
end;

function getprocInputHandler: ICEProcInputHandler;
begin
  exit(EntitiesConnector.getSingleService('ICEProcInputHandler') as ICEProcInputHandler);
end;

function getMultiDocHandler(var obj: ICEMultiDocHandler): ICEMultiDocHandler;
begin
  if obj = nil then
    obj := EntitiesConnector.getSingleService('ICEMultiDocHandler') as ICEMultiDocHandler;
  exit(obj);
end;

function getMultiDocHandler: ICEMultiDocHandler;
begin
  exit(EntitiesConnector.getSingleService('ICEMultiDocHandler') as ICEMultiDocHandler);
end;

function getSymStringExpander: ICESymStringExpander;
begin
  exit(EntitiesConnector.getSingleService('ICESymStringExpander') as ICESymStringExpander);
end;

function getProjectGroup: ICEProjectGroup;
begin
  exit(EntitiesConnector.getSingleService('ICEProjectGroup') as ICEProjectGroup);
end;

function getExplorer: ICEExplorer;
begin
  exit(EntitiesConnector.getSingleService('ICEExplorer') as ICEExplorer);
end;

function getOptionsEditor: ICEOptionsEditor;
begin
  exit(EntitiesConnector.getSingleService('ICEOptionsEditor') as ICEOptionsEditor);
end;

function getCompilerSelector: ICECompilerSelector;
begin
  exit(EntitiesConnector.getSingleService('ICECompilerSelector') as ICECompilerSelector);
end;

function getMainMenu: ICEMainMenu;
begin
  exit(EntitiesConnector.getSingleService('ICEMainMenu') as ICEMainMenu);
end;

function getCodeFormatting: ICECodeFormatting; inline;
begin
  exit(EntitiesConnector.getSingleService('ICECodeFormatting') as ICECodeFormatting);
end;

function getLifeTimeManager: ICELifetimeManager; inline;
begin
  exit(EntitiesConnector.getSingleService('ICELifetimeManager') as ICELifetimeManager);
end;
{$ENDREGION}

function usingCompilerInfo(value: DCompiler): string;
const
  c2id: array[DCompiler] of string = ('dmd', 'gdc', 'gdmd', 'ldc', 'ldmd',
    'user1', 'user2');
begin
  result := format('using %s (%s)',
    [getCompilerSelector.getCompilerPath(value), c2id[value]]);
end;

end.
