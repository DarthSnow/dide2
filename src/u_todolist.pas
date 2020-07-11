unit u_todolist;

{$I u_defines.inc}

interface

uses
  Classes, SysUtils, FileUtil, ListFilterEdit, Forms, Controls,
  strutils, Graphics, Dialogs, ExtCtrls, Menus, Buttons, ComCtrls,
  syncobjs,
  u_widget, process, u_common, u_interfaces, u_synmemo, u_processes,
  u_writableComponent, u_observer, u_sharedres, u_dexed_d,
  u_dsgncontrols;

type

  TTodoColumn = (filename, line, text, priority, assignee, category, status);
  TTodoColumns = set of TTodoColumn;

  TTodoOptions = class(TWritableLfmTextComponent)
  private
    fAutoRefresh: boolean;
    fSingleClick: boolean;
    fColumns: TTodoColumns;
    fdisableIfMoreFilesThan: integer;
  published
    property autoRefresh: boolean read fAutoRefresh write fAutoRefresh;
    property singleClickSelect: boolean read fSingleClick write fSingleClick;
    property columns: TTodoColumns read fColumns write fColumns;
    property disableIfMoreFilesThan: integer read fdisableIfMoreFilesThan write fdisableIfMoreFilesThan default 25;
  public
    procedure AssignTo(target: TPersistent); override;
    procedure Assign(source: TPersistent); override;
    constructor create(AOwner: TComponent); override;
  end;

  TTodoContext = (tcNone, tcProject, tcFile);

  // represents a TODO item
  // warning: the props names must be kept in sync with the values set in the tool.
  TTodoItem = class(TCollectionItem)
  private
    fFile: string;
    fLine: string;
    fText: string;
    fPriority: string;
    fAssignee: string;
    fCategory: string;
    fStatus: string;
  published
    property filename: string read fFile write fFile;
    property line: string read fLine write fLine;
    property text: string read fText write fText;
    property assignee: string read fAssignee write fAssignee;
    property category: string read fCategory write fCategory;
    property status: string read fStatus write fStatus;
    property priority: string read fPriority write fPriority;
  end;

  // encapsulates / makes serializable a collection of TODO item.
  // warning: the class name must be kept in sync with the value set in the tool.
  TTodoItems = class(TComponent)
  private
    fItems: TCollection;
    procedure setItems(value: TCollection);
    function getItem(index: Integer): TTodoItem;
    function getCount: integer;
  published
    // warning, "items" must be kept in sync with...
    property items: TCollection read fItems write setItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // str is the output stream of the tool process.
    procedure loadFromTxtStream(str: TMemoryStream);
    property Count: integer read getCount;
    property item[index: integer]: TTodoItem read getItem; default;
  end;

  { TTodoListWidget }

  TTodoListWidget = class(TDexedWidget, IDocumentObserver, IProjectObserver, IEditableOptions)
    btnGo: TDexedToolButton;
    btnRefresh: TDexedToolButton;
    lstItems: TListView;
    lstfilter: TListFilterEdit;
    mnuAutoRefresh: TMenuItem;
    procedure handleListClick(Sender: TObject);
    procedure mnuAutoRefreshClick(Sender: TObject);
    procedure toolbarResize(Sender: TObject);
  private
    fFileListForThread: string;
    fSerializedTodoItemFromThread: string;
    fLockItemsScanning: boolean;
    fAutoRefresh: Boolean;
    fSingleClick: Boolean;
    fColumns: TTodoColumns;
    fProj: ICommonProject;
    fDoc: TDexedMemo;
    fTodos: TTodoItems;
    fOptions: TTodoOptions;
    // IDocumentObserver
    procedure docNew(document: TDexedMemo);
    procedure docFocused(document: TDexedMemo);
    procedure docChanged(document: TDexedMemo);
    procedure docClosing(document: TDexedMemo);
    // IProjectObserver
    procedure projNew(project: ICommonProject);
    procedure projChanged(project: ICommonProject);
    procedure projClosing(project: ICommonProject);
    procedure projFocused(project: ICommonProject);
    procedure projCompiling(project: ICommonProject);
    procedure projCompiled(project: ICommonProject; success: boolean);
    // IEditableOptions
    function optionedWantCategory(): string;
    function optionedWantEditorKind: TOptionEditorKind;
    function optionedWantContainer: TPersistent;
    procedure optionedEvent(event: TOptionEditorEvent);
    function optionedOptionsModified: boolean;
    // TODOlist things
    function getContext: TTodoContext;
    procedure scanTodoItems(autoRefreshed: boolean);
    procedure threadedScanning;
    procedure threadedScanningFinished(Sender : TObject);
    procedure clearTodoList;
    procedure fillTodoList;
    procedure lstItemsColumnClick(Sender: TObject; Column: TListColumn);
    procedure lstItemsCompare(Sender: TObject; item1, item2: TListItem; Data: Integer; var Compare: Integer);
    procedure btnRefreshClick(Sender: TObject);
    procedure filterItems(Sender: TObject);
    procedure setSingleClick(value: boolean);
    procedure setAutoRefresh(value: boolean);
    procedure setColumns(value: TTodoColumns);
    procedure refreshVisibleColumns;
  protected
    procedure SetVisible(value: boolean); override;
    procedure setToolBarFlat(value: boolean); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    //
    property singleClickSelect: boolean read fSingleClick write setSingleClick;
    property autoRefresh: boolean read fAutoRefresh write setAutoRefresh;
    property columns: TTodoColumns read fColumns write setColumns;
  end;

implementation

{$R *.lfm}

const
  OptFname = 'todolist.txt';

{$REGION TTodoItems ------------------------------------------------------------}
constructor TTodoItems.Create(aOwner: TComponent);
begin
  inherited;
  fItems := TCollection.Create(TTodoItem);
end;

destructor TTodoItems.Destroy;
begin
  fItems.Free;
  inherited;
end;

procedure TTodoItems.setItems(value: TCollection);
begin
  fItems.Assign(value);
end;

function TTodoItems.getItem(index: Integer): TTodoItem;
begin
  Result := TTodoItem(fItems.Items[index]);
end;

function TTodoItems.getCount: integer;
begin
  Result := fItems.Count;
end;

procedure TTodoItems.loadFromTxtStream(str: TMemoryStream);
var
  bin: TMemoryStream;
begin
  // empty collection ~ length
  if str.Size < 50 then
    exit;
  //
  try
    bin := TMemoryStream.Create;
    try
      str.Position := 0;
      ObjectTextToBinary(str, bin);
      bin.Position := 0;
      bin.ReadComponent(self);
    finally
      bin.Free;
    end;
  except
    fItems.Clear;
  end;
end;
{$ENDREGIOn}

{$REGION Standard Comp/Obj -----------------------------------------------------}
constructor TTodoListWidget.Create(aOwner: TComponent);
var
  fname: string;
begin
  inherited;

  Case GetIconScaledSize of
    iss16: AssignPng(lstfilter.Glyph, 'FILTER_CLEAR');
    iss24: AssignPng(lstfilter.Glyph, 'FILTER_CLEAR24');
    iss32: AssignPng(lstfilter.Glyph, 'FILTER_CLEAR32');
  end;
  lstfilter.BorderSpacing.Left := scaleX(58, 96);

  columns:= [TTodoColumn.filename .. TTodoColumn.line];
  fOptions := TTodoOptions.Create(self);
  fOptions.autoRefresh := True;
  fOptions.Name := 'todolistOptions';

  fTodos := TTodoItems.Create(self);
  lstItems.OnDblClick := @handleListClick;
  btnRefresh.OnClick := @btnRefreshClick;
  lstItems.OnColumnClick := @lstItemsColumnClick;
  lstItems.OnCompare := @lstItemsCompare;
  fAutoRefresh := True;
  fSingleClick := False;
  mnuAutoRefresh.Checked := True;
  lstfilter.OnChange := @filterItems;
  btnGo.OnClick := @handleListClick;

  fname := getDocPath + OptFname;
  if fname.fileExists then
  begin
    fOptions.loadFromFile(fname);
    fOptions.AssignTo(self);
  end;

  EntitiesConnector.addObserver(self);
end;

destructor TTodoListWidget.Destroy;
begin
  fOptions.saveToFile(getDocPath + OptFname);
  inherited;
end;

procedure TTodoListWidget.SetVisible(value: boolean);
begin
  inherited;
  if value and fAutoRefresh then
    scanTodoItems(true);
  refreshVisibleColumns;
end;

procedure TTodoListWidget.setToolBarFlat(value: boolean);
begin
  inherited setToolBarFlat(value);
  lstfilter.Flat:=value;
end;
{$ENDREGION}

{$REGION IEditableOptions ----------------------------------------------------}
constructor TTodoOptions.create(AOwner: TComponent);
begin
  inherited create(aOwner);
  fdisableIfMoreFilesThan := 25;
end;

procedure TTodoOptions.AssignTo(target: TPersistent);
var
  widg: TTodoListWidget;
begin
  if target is TTodoListWidget then
  begin
    widg := TTodoListWidget(target);
    widg.singleClickSelect := fSingleClick;
    widg.autoRefresh := fAutoRefresh;
    widg.columns := fColumns;
  end
  else
    inherited;
end;

procedure TTodoOptions.Assign(source: TPersistent);
var
  widg: TTodoListWidget;
begin
  if source is TTodoListWidget then
  begin
    widg := TTodoListWidget(source);
    fSingleClick := widg.singleClickSelect;
    fAutoRefresh := widg.autoRefresh;
    fColumns:=widg.columns;
  end
  else
    inherited;
end;

function TTodoListWidget.optionedWantCategory(): string;
begin
  exit('Todo list');
end;

function TTodoListWidget.optionedWantEditorKind: TOptionEditorKind;
begin
  exit(oekGeneric);
end;

function TTodoListWidget.optionedWantContainer: TPersistent;
begin
  fOptions.Assign(self);
  exit(fOptions);
end;

procedure TTodoListWidget.optionedEvent(event: TOptionEditorEvent);
begin
  if event <> oeeAccept then
    exit;
  fOptions.AssignTo(self);
end;

function TTodoListWidget.optionedOptionsModified: boolean;
begin
  exit(false);
end;
{$ENDREGION}

{$REGION IDocumentObserver ---------------------------------------------------}
procedure TTodoListWidget.docNew(document: TDexedMemo);
begin
  fDoc := document;
  if Visible and fAutoRefresh then
    scanTodoItems(true);
end;

procedure TTodoListWidget.docFocused(document: TDexedMemo);
begin
  if fDoc = document then
    exit;
  fDoc := document;
  if fDoc.isAssigned and Visible and fAutoRefresh then
    scanTodoItems(true);
end;

procedure TTodoListWidget.docChanged(document: TDexedMemo);
begin
end;

procedure TTodoListWidget.docClosing(document: TDexedMemo);
begin
  if fDoc <> document then
    exit;
  fDoc := nil;
  if Visible and fAutoRefresh then
    clearTodoList;
end;
{$ENDREGION}

{$REGION IProjectObserver ----------------------------------------------------}
procedure TTodoListWidget.projNew(project: ICommonProject);
begin
  fProj := project;
end;

procedure TTodoListWidget.projChanged(project: ICommonProject);
begin
  if fProj <> project then
    exit;
  if Visible and fAutoRefresh then
    scanTodoItems(true);
end;

procedure TTodoListWidget.projClosing(project: ICommonProject);
begin
  if fProj <> project then
    exit;
  fProj := nil;
  if Visible and fAutoRefresh then
    scanTodoItems(true);
end;

procedure TTodoListWidget.projFocused(project: ICommonProject);
begin
  if fProj = project then
    exit;
  fProj := project;
  if Visible and fAutoRefresh then
    scanTodoItems(true);
end;

procedure TTodoListWidget.projCompiling(project: ICommonProject);
begin
end;

procedure TTodoListWidget.projCompiled(project: ICommonProject; success: boolean);
begin
end;
{$ENDREGION}

{$REGION Todo list things ------------------------------------------------------}
function TTodoListWidget.getContext: TTodoContext;
begin
  if fProj.isNotAssigned and fDoc.isNotAssigned then
    exit(tcNone);
  if fProj.isNotAssigned and fDoc.isAssigned then
    exit(tcFile);
  if fProj.isAssigned and fDoc.isNotAssigned then
    exit(tcProject);

  if fProj.isSource(fDoc.fileName) then
    exit(tcProject)
  else
    exit(tcFile);
end;

procedure TTodoListWidget.scanTodoItems(autoRefreshed: boolean);
var
  c: TTodoContext;
  i: integer;
  j: integer;
  n: string;
begin
  if fLockItemsScanning then
    exit;

  fFileListForThread := '';
  clearTodoList;

  c := getContext;
  case c of
    tcNone: exit;
    tcProject: if (fProj = nil) or fProj.sourcesCount.equals(0) then
      exit;
    tcFile: if fDoc = nil then
      exit;
  end;

  if c = tcProject then
  begin
    j := fProj.sourcesCount-1;
    if autoRefreshed and (j > fOptions.disableIfMoreFilesThan) then
      exit;
    for i := 0 to j do
    begin
      n := fProj.sourceAbsolute(i);
      if not hasDlangSyntax(n.extractFileExt) then
        continue;
      if not n.fileExists then
        continue;
      fFileListForThread += n;
      if i <> j then
        fFileListForThread += PathSeparator;
    end;
  end
  else if fDoc.fileName <> newdocPageCaption then
  begin
    fFileListForThread := fDoc.fileName;
  end;

  if fFileListForThread.isNotEmpty then
  begin
    fLockItemsScanning := true;
    TThread.ExecuteInThread(@threadedScanning, @threadedScanningFinished);
  end;

end;

procedure TTodoListWidget.threadedScanning;
begin
  fSerializedTodoItemFromThread := string(todoItems(PChar(fFileListForThread)));
end;

procedure TTodoListWidget.threadedScanningFinished(Sender : TObject);
var
  txt: TmemoryStream;
begin
  if fSerializedTodoItemFromThread.length < 10 then
    exit;
  txt := TMemoryStream.create;
  try
    txt.Write(fSerializedTodoItemFromThread[1], fSerializedTodoItemFromThread.length);
    txt.Position := 0;
    fTodos.loadFromTxtStream(txt);
    fillTodoList;
  finally
    txt.free;
    minimizeGcHeap();
  end;
end;

procedure TTodoListWidget.clearTodoList;
begin
  lstItems.BeginUpdate;
  lstItems.Clear;
  fTodos.items.Clear;
  lstItems.EndUpdate;
end;

procedure TTodoListWidget.fillTodoList;
var
  i: integer;
  src: TTodoItem;
  trg: TListItem;
  flt: string;
begin
  lstItems.BeginUpdate;
  lstItems.Clear;
  lstItems.Column[1].Visible := False;
  lstItems.Column[2].Visible := False;
  lstItems.Column[3].Visible := False;
  lstItems.Column[4].Visible := False;
  flt := lstfilter.Text;
  for i := 0 to fTodos.Count - 1 do
  begin
    src := fTodos[i];
    trg := lstItems.Items.Add;
    trg.Data := src;
    trg.Caption := src.Text;
    trg.SubItems.Add(src.category);
    trg.SubItems.Add(src.assignee);
    trg.SubItems.Add(src.status);
    trg.SubItems.Add(src.priority);
    trg.SubItems.Add(shortenPath(src.filename, 25));
    //
    if flt.isNotEmpty then
      if flt <> '(filter)' then
        if not AnsiContainsText(src.Text, flt) then
          if not AnsiContainsText(src.category, flt) then
            if not AnsiContainsText(src.assignee, flt) then
              if not AnsiContainsText(src.status, flt) then
                if not AnsiContainsText(src.priority, flt) then
                begin
                  lstItems.Items.Delete(trg.Index);
                  continue;
                end;
    //
    if src.category.isNotEmpty then
      lstItems.Column[1].Visible := True;
    if src.assignee.isNotEmpty then
      lstItems.Column[2].Visible := True;
    if src.status.isNotEmpty then
      lstItems.Column[3].Visible := True;
    if src.priority.isNotEmpty then
      lstItems.Column[4].Visible := True;
  end;
  lstItems.EndUpdate;
  fLockItemsScanning := false;
end;

procedure TTodoListWidget.handleListClick(Sender: TObject);
var
  itm: TTodoItem;
  fname, ln: string;
begin
  if lstItems.Selected.isNotAssigned or lstItems.Selected.Data.isNotAssigned then
    exit;

  // the collection will be cleared if a file is opened
  // docFocused->scanTodoItems->fTodos....clear
  // so line and filename must be copied
  itm := TTodoItem(lstItems.Selected.Data);
  fname := itm.filename;
  ln := itm.line;
  getMultiDocHandler.openDocument(fname);

  if fDoc.isNotAssigned then
    exit;

  fDoc.setFocus;
  fDoc.CaretY := StrToInt(ln);
  fDoc.SelectLine;
end;

procedure TTodoListWidget.mnuAutoRefreshClick(Sender: TObject);
begin
  autoRefresh := mnuAutoRefresh.Checked;
  fOptions.autoRefresh := autoRefresh;
end;

procedure TTodoListWidget.toolbarResize(Sender: TObject);
begin
  lstfilter.Width := toolbar.Width - lstfilter.Left - lstfilter.BorderSpacing.Around;
end;

procedure TTodoListWidget.lstItemsColumnClick(Sender: TObject; Column: TListColumn);
var
  curr: TListItem;
begin
  if lstItems.Selected.isNotAssigned then
    exit;
  lstItems.BeginUpdate;
  curr := lstItems.Selected;
  //
  if lstItems.SortDirection = sdAscending then
    lstItems.SortDirection := sdDescending
  else
    lstItems.SortDirection := sdAscending;
  lstItems.SortColumn := Column.Index;
  lstItems.Selected := nil;
  lstItems.Selected := curr;
  lstItems.EndUpdate;
end;

procedure TTodoListWidget.lstItemsCompare(Sender: TObject; item1, item2: TListItem; Data: Integer; var Compare: Integer);
var
  txt1: string = '';
  txt2: string = '';
  col: Integer;
begin
  col := lstItems.SortColumn;
  if col.equals(0) then
  begin
    txt1 := item1.Caption;
    txt2 := item2.Caption;
  end
  else
  begin
    col -= 1;
    if col < item1.SubItems.Count then
      txt1 := item1.SubItems[col];
    if col < item2.SubItems.Count then
      txt2 := item2.SubItems[col];
  end;
  Compare := AnsiCompareStr(txt1, txt2);
  if lstItems.SortDirection = sdDescending then
    Compare := -Compare;
end;

procedure TTodoListWidget.btnRefreshClick(Sender: TObject);
begin
  scanTodoItems(false);
end;

procedure TTodoListWidget.filterItems(Sender: TObject);
begin
  fillTodoList;
end;

procedure TTodoListWidget.setSingleClick(value: boolean);
begin
  fSingleClick := value;
  if fSingleClick then
  begin
    lstItems.OnClick := @handleListClick;
    lstItems.OnDblClick := nil;
  end
  else
  begin
    lstItems.OnClick := nil;
    lstItems.OnDblClick := @handleListClick;
  end;
end;

procedure TTodoListWidget.setAutoRefresh(value: boolean);
begin
  fAutoRefresh := value;
  mnuAutoRefresh.Checked := value;
  if fAutoRefresh then
    scanTodoItems(true);
end;

procedure TTodoListWidget.setColumns(value: TTodoColumns);
begin
  fColumns := value;
  refreshVisibleColumns;
end;

procedure TTodoListWidget.refreshVisibleColumns;
begin

  if lstItems.isNotAssigned then
    exit;
  if lstItems.Columns.isNotAssigned then
    exit;
  if lstItems.ColumnCount <> 6 then
    exit;

  lstItems.BeginUpdate;
  lstItems.Column[1].Visible := TTodoColumn.category in fColumns ;
  lstItems.Column[2].Visible := TTodoColumn.assignee in fColumns ;
  lstItems.Column[3].Visible := TTodoColumn.status in fColumns ;
  lstItems.Column[4].Visible := TTodoColumn.priority in fColumns ;
  lstItems.Column[5].Visible := TTodoColumn.filename in fColumns ;
  lstItems.EndUpdate;
end;
{$ENDREGION}

end.
