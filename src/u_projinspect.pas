unit u_projinspect;

{$I u_defines.inc}

interface

uses
  Classes, SysUtils, TreeFilterEdit, Forms, Controls, Graphics, actnlist,
  Dialogs, ExtCtrls, ComCtrls, Menus, Buttons, lcltype, StdCtrls, u_ceproject,
  u_interfaces, u_common, u_widget, u_observer, u_dialogs, u_sharedres,
  u_dsgncontrols, u_dubproject, u_synmemo, u_stringrange, u_writableComponent;

type

  TProjectInspectorOptions = class(TWritableLfmTextComponent)
  private
    fFileListAsTree: boolean;
  published
    property fileListAsTree: boolean read fFileListAsTree write fFileListAsTree;
  end;

  { TProjectInspectWidget }

  TProjectInspectWidget = class(TDexedWidget, IProjectObserver, IDocumentObserver)
    btnAddFile: TDexedToolButton;
    btnAddFold: TDexedToolButton;
    btnReload: TDexedToolButton;
    btnRemFile: TDexedToolButton;
    btnRemFold: TDexedToolButton;
    btnTree: TDexedToolButton;
    selConf: TComboBox;
    Tree: TTreeView;
    TreeFilterEdit1: TTreeFilterEdit;
    procedure btnAddFileClick(Sender: TObject);
    procedure btnAddFoldClick(Sender: TObject);
    procedure btnRemFileClick(Sender: TObject);
    procedure btnRemFoldClick(Sender: TObject);
    procedure btnTreeClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const fnames: array of String);
    procedure selConfChange(Sender: TObject);
    procedure toolbarResize(Sender: TObject);
    procedure TreeClick(Sender: TObject);
    procedure TreeDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeSelectionChanged(Sender: TObject);
  protected
    procedure updateImperative; override;
    procedure updateDelayed; override;
    procedure SetVisible(value: boolean); override;
    procedure setToolBarFlat(value: boolean); override;
  private
    fActOpenFile: TAction;
    fActBuildConf: TAction;
    fProj: ICommonProject;
    fFileNode: TTreeNode;
    fLastFileOrFolder: string;
    fSymStringExpander: ISymStringExpander;
    fImages: TImageList;
    fFileListAsTree: boolean;
    procedure actUpdate(sender: TObject);
    procedure DetectNewDubSources(const document: TDexedMemo);
    procedure TreeDblClick(sender: TObject);
    procedure actOpenFileExecute(sender: TObject);
    procedure actBuildExecute(sender: TObject);
    //
    procedure projNew(project: ICommonProject);
    procedure projClosing(project: ICommonProject);
    procedure projFocused(project: ICommonProject);
    procedure projChanged(project: ICommonProject);
    procedure projCompiling(project: ICommonProject);
    procedure projCompiled(project: ICommonProject; success: boolean);
    procedure updateButtons;
    procedure setFileListAsTree(value: boolean);
    //
    procedure docNew(document: TDexedMemo);
    procedure docFocused(document: TDexedMemo);
    procedure docChanged(document: TDexedMemo);
    procedure docClosing(document: TDexedMemo);
  protected
    function contextName: string; override;
    function contextActionCount: integer; override;
    function contextAction(index: integer): TAction; override;
  public
    constructor create(aOwner: TComponent); override;
    destructor destroy; override;
    property fileListAsTree: boolean read fFileListAsTree write setFileListAsTree;
  end;

implementation
{$R *.lfm}

const optFname = 'projinspect.txt';
const filterAlign: array[boolean] of integer = (58, 162);

{$REGION Standard Comp/Obj------------------------------------------------------}
constructor TProjectInspectWidget.create(aOwner: TComponent);
var
  fname: string;
begin
  fSymStringExpander:= getSymStringExpander;

  fActOpenFile := TAction.Create(self);
  fActOpenFile.Caption := 'Open file(s) in editor';
  fActOpenFile.OnExecute := @actOpenFileExecute;
  fActBuildConf:= TAction.Create(self);
  fActBuildConf.Caption := 'Build configuration';
  fActBuildConf.OnExecute := @actBuildExecute;
  fActBuildConf.OnUpdate := @actUpdate;

  inherited;

  fImages := TImageList.Create(self);
  case GetIconScaledSize of
    iss16:
    begin
      fImages.Width := 16;
      fImages.Height := 16;
      Tree.Indent := 16;
      fImages.AddResourceName(HINSTANCE, 'DOCUMENT_ALL');
      fImages.AddResourceName(HINSTANCE, 'WRENCH');
      fImages.AddResourceName(HINSTANCE, 'PAGE_TEXT');
      fImages.AddResourceName(HINSTANCE, 'COG');
      fImages.AddResourceName(HINSTANCE, 'COG_GO');
      fImages.AddResourceName(HINSTANCE, 'FOLDER');
      AssignPng(TreeFilterEdit1.Glyph, 'FILTER_CLEAR');
    end;
    iss24:
    begin
      fImages.Width := 24;
      fImages.Height := 24;
      Tree.Indent := 24;
      fImages.AddResourceName(HINSTANCE, 'DOCUMENT_ALL24');
      fImages.AddResourceName(HINSTANCE, 'WRENCH24');
      fImages.AddResourceName(HINSTANCE, 'PAGE_TEXT24');
      fImages.AddResourceName(HINSTANCE, 'COG24');
      fImages.AddResourceName(HINSTANCE, 'COG_GO24');
      fImages.AddResourceName(HINSTANCE, 'FOLDER24');
      AssignPng(TreeFilterEdit1.Glyph, 'FILTER_CLEAR24');
    end;
    iss32:
    begin
      fImages.Width := 32;
      fImages.Height := 32;
      Tree.Indent := 32;
      fImages.AddResourceName(HINSTANCE, 'DOCUMENT_ALL32');
      fImages.AddResourceName(HINSTANCE, 'WRENCH32');
      fImages.AddResourceName(HINSTANCE, 'PAGE_TEXT32');
      fImages.AddResourceName(HINSTANCE, 'COG32');
      fImages.AddResourceName(HINSTANCE, 'COG_GO32');
      fImages.AddResourceName(HINSTANCE, 'FOLDER32');
      AssignPng(TreeFilterEdit1.Glyph, 'FILTER_CLEAR32');
    end;
  end;

  Tree.OnDblClick := @TreeDblClick;
  fFileNode := Tree.Items[0];

  Tree.Images := fImages;
  Tree.PopupMenu := contextMenu;
  TreeFilterEdit1.BorderSpacing.Left := ScaleX(filterAlign[false], 96);
  toolbarResize(nil);

  fname := getDocPath + optFname;
  if fname.fileExists then
  begin
    with TProjectInspectorOptions.Create(nil) do
    try
      loadFromFile(fname);
      self.setFileListAsTree(fileListAsTree);
      btnTree.Down:=fileListAsTree;
    finally
      free;
    end;
  end;

  timedUpdateKind := tukDelay;

  EntitiesConnector.addObserver(self);
end;

destructor TProjectInspectWidget.destroy;
begin
  with TProjectInspectorOptions.Create(nil) do
  try
    fileListAsTree:= self.fileListAsTree;
    saveToFile(getDocPath + optFname);
  finally
    free;
  end;
  EntitiesConnector.removeObserver(self);
  inherited;
end;

procedure TProjectInspectWidget.SetVisible(value: boolean);
begin
  inherited;
  if value then
    updateImperative;
end;

procedure TProjectInspectWidget.setToolBarFlat(value: boolean);
begin
  inherited setToolBarFlat(value);
  TreeFilterEdit1.Flat:=value;
end;
{$ENDREGION}

{$REGION IContextualActions---------------------------------------------------}
function TProjectInspectWidget.contextName: string;
begin
  exit('Inspector');
end;

function TProjectInspectWidget.contextActionCount: integer;
begin
  exit(2);
end;

function TProjectInspectWidget.contextAction(index: integer): TAction;
begin
  case index of
    0: exit(fActOpenFile);
    1: exit(fActBuildConf);
    else exit(nil);
  end;
end;

procedure TProjectInspectWidget.actOpenFileExecute(sender: TObject);
begin
  TreeDblClick(sender);
end;

procedure TProjectInspectWidget.actBuildExecute(sender: TObject);
begin
  if fProj.isAssigned then
  begin
    actOpenFileExecute(sender);
    fProj.compile;
  end;
end;
{$ENDREGION}

{$REGION IDocumentObserver ---------------------------------------------------}
procedure TProjectInspectWidget.docNew(document: TDexedMemo);
begin
  DetectNewDubSources(document);
end;

procedure TProjectInspectWidget.docFocused(document: TDexedMemo);
begin
  DetectNewDubSources(document);
end;

procedure TProjectInspectWidget.docChanged(document: TDexedMemo);
begin
end;

procedure TProjectInspectWidget.docClosing(document: TDexedMemo);
begin
  DetectNewDubSources(document);
end;
{$ENDREGION}

{$REGION IProjectObserver -----------------------------------------------------}
procedure TProjectInspectWidget.projNew(project: ICommonProject);
begin
  fLastFileOrFolder := '';
  fProj := project;
  if Visible then
    updateImperative;
  updateButtons;
end;

procedure TProjectInspectWidget.projClosing(project: ICommonProject);
begin
  if fProj.isNotAssigned then
    exit;
  if project <> fProj then
    exit;
  fProj := nil;
  fLastFileOrFolder := '';
  updateImperative;
end;

procedure TProjectInspectWidget.projFocused(project: ICommonProject);
begin
  fLastFileOrFolder := '';
  fProj := project;
  TreeFilterEdit1.Text:= '';
  DetectNewDubSources(nil);
  updateButtons;
  if Visible then
    beginDelayedUpdate;
end;

procedure TProjectInspectWidget.projChanged(project: ICommonProject);
begin
  if fProj.isNotAssigned  then
    exit;
  if fProj <> project then
    exit;
  if Visible then
    beginDelayedUpdate;
end;

procedure TProjectInspectWidget.projCompiling(project: ICommonProject);
begin
end;

procedure TProjectInspectWidget.projCompiled(project: ICommonProject; success: boolean);
begin
end;

procedure TProjectInspectWidget.updateButtons;
var
  ce: boolean;
  sp: integer;
begin
  ce := fProj.getFormat = pfDEXED;

  btnRemFold.Visible:= ce;
  btnAddFold.Visible:= ce;
  btnRemFile.Visible:= ce;
  btnAddFile.Visible:= ce;

  TreeFilterEdit1.Left := toolbar.Width - 5;
  sp := scaleX(2, 96);
  if ce then
    TreeFilterEdit1.Left  := btnRemFold.Left + btnRemFold.Width + 2
  else
    TreeFilterEdit1.Left  := btnTree.Left + btnRemFold.Width + 2;
  TreeFilterEdit1.width := toolbar.Width - TreeFilterEdit1.Left - sp;
  TreeFilterEdit1.top   := sp;
  TreeFilterEdit1.Height:= toolbar.Height - sp * 2;
end;

procedure TProjectInspectWidget.setFileListAsTree(value: boolean);
begin
  if fFileListAsTree = value then
    exit;
  fFileListAsTree:=value;
  updateImperative;
end;

{$ENDREGION}

{$REGION Inspector things -------------------------------------------------------}
procedure TProjectInspectWidget.TreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    TreeDblClick(nil);
end;

procedure TProjectInspectWidget.TreeClick(Sender: TObject);
begin
  if Tree.Selected.isAssigned then
  begin
    Tree.MultiSelect := Tree.Selected.Parent = fFileNode;
    if Tree.Selected.isNotAssigned() then
      exit;
    if not (Tree.Selected.Parent = fFileNode) then
    begin
      Tree.MultiSelect := false;
      Tree.ClearSelection(true);
      Tree.Selected.MultiSelected:=false;
    end;
  end
  else
  begin
    Tree.MultiSelect := false;
    Tree.ClearSelection(true);
  end;
end;

procedure TProjectInspectWidget.TreeDeletion(Sender: TObject; Node: TTreeNode
  );
begin
  if Node.isAssigned and Node.Data.isAssigned then
    dispose(PString(Node.Data));
end;

procedure TProjectInspectWidget.TreeSelectionChanged(Sender: TObject);
begin
  actUpdate(sender);
  if fProj.isNotAssigned or Tree.Selected.isNotAssigned then
    exit;
  if (Tree.Selected.Parent = fFileNode) then
    fLastFileOrFolder := expandFilenameEx(fProj.basePath,tree.Selected.Text)
  else
    fLastFileOrFolder := tree.Selected.Text;
end;

procedure TProjectInspectWidget.TreeDblClick(sender: TObject);
var
  f: string;
  i: integer;
begin
  if fProj.isNotAssigned or Tree.Selected.isNotAssigned then
    exit;
  for i := 0 to Tree.SelectionCount - 1 do
    if Tree.Selections[i].Data.isAssigned() then
  begin
    f := PString(Tree.Selections[i].Data)^;
    if isEditable(f.extractFileExt) and f.fileExists then
      getMultiDocHandler.openDocument(f);
  end;
  Tree.Selected := nil;
end;

procedure TProjectInspectWidget.actUpdate(sender: TObject);
begin
  fActOpenFile.Enabled := false;
  fActBuildConf.Enabled:= false;
  if Tree.Selected.isNotAssigned then
    exit;
  fActBuildConf.Enabled := true;
  fActOpenFile.Enabled := Tree.Selected.ImageIndex = 2;
end;

procedure TProjectInspectWidget.DetectNewDubSources(const document: TDexedMemo);
begin
  if fProj.isNotAssigned or (fProj.getFormat <> pfDUB) then
    exit;
  if document.isAssigned then
  begin
    if document.fileName.contains(fProj.basePath) then
      TDubProject(fProj.getProject).updateSourcesList;
  end
  else TDubProject(fProj.getProject).updateSourcesList;
  //updateImperative;
end;

procedure TProjectInspectWidget.btnAddFileClick(Sender: TObject);
var
  fname: string;
  proj: TNativeProject;
begin
  if fProj.isNotAssigned or (fProj.getFormat = pfDUB) then
    exit;

  proj := TNativeProject(fProj.getProject);
  with TOpenDialog.Create(nil) do
  try
    options := options + [ofAllowMultiSelect];
    if fLastFileOrFolder.fileExists then
      InitialDir := fLastFileOrFolder.extractFilePath
    else if fLastFileOrFolder.dirExists then
      InitialDir := fLastFileOrFolder;
    filter := DdiagFilter;
    if execute then
    begin
      proj.beginUpdate;
      for fname in Files do
        proj.addSource(fname.normalizePath);
      proj.endUpdate;
    end;
  finally
    free;
  end;
end;

procedure TProjectInspectWidget.btnAddFoldClick(Sender: TObject);
var
  dir, fname: string;
  lst: TStringList;
  proj: TNativeProject;
  i: integer;
begin
  if fProj.isNotAssigned or (fProj.getFormat = pfDUB) then
    exit;

  dir := '';
  proj := TNativeProject(fProj.getProject);
  if fLastFileOrFolder.fileExists then
    dir := fLastFileOrFolder.extractFilePath
  else if fLastFileOrFolder.dirExists then
    dir := fLastFileOrFolder
  else if fProj.fileName.fileExists then
    dir := fProj.fileName.extractFilePath;
  if selectDirectory('sources', dir, dir, true, 0) then
  begin
    proj.beginUpdate;
    lst := TStringList.Create;
    try
      listFiles(lst, dir, true);
      for i := 0 to lst.Count-1 do
      begin
        fname := lst[i];
        if isDlangCompilable(fname.extractFileExt) then
          proj.addSource(fname);
      end;
    finally
      lst.Free;
      proj.endUpdate;
    end;
  end;
end;

procedure TProjectInspectWidget.btnRemFoldClick(Sender: TObject);
var
  dir, fname: string;
  proj: TNativeProject;
  i: Integer;
begin
  if fProj.isNotAssigned or (fProj.getFormat = pfDUB)
  or Tree.Selected.isNotAssigned or (Tree.Selected.Parent <> fFileNode) then
    exit;

  proj := TNativeProject(fProj.getProject);
  fname := Tree.Selected.Text;
  i := proj.Sources.IndexOf(fname);
  if i.equals(-1) then
    exit;
  fname := fProj.sourceAbsolute(i);
  dir := fname.extractFilePath;
  if not dir.dirExists then
    exit;

  proj.beginUpdate;
  for i:= proj.Sources.Count-1 downto 0 do
    if proj.sourceAbsolute(i).extractFilePath = dir then
      proj.Sources.Delete(i);
  proj.endUpdate;
end;

procedure TProjectInspectWidget.btnTreeClick(Sender: TObject);
begin
  setFileListAsTree(btnTree.Down);
end;

procedure TProjectInspectWidget.btnReloadClick(Sender: TObject);
var
  f: string;
begin
  if fProj.isNotAssigned then
    exit;

  f := fProj.filename;
  if not f.fileExists then
    exit;
  if fProj.modified and
    (dlgYesNo('The project seems to be modified, save before reloading') = mrYes) then
      fProj.saveToFile(f);
  fProj.loadFromFile(f);
end;

procedure TProjectInspectWidget.btnRemFileClick(Sender: TObject);
var
  fname: string;
  proj: TNativeProject;
  i, j: integer;
begin
  if fProj.isNotAssigned or (fProj.getFormat = pfDUB)
  or Tree.Selected.isNotAssigned or (Tree.Selected.Parent <> fFileNode) then
    exit;

  proj := TNativeProject(fProj.getProject);
  proj.beginUpdate;
  for j:= 0 to Tree.SelectionCount-1 do
  begin
    fname := Tree.Selections[j].Text;
    i := proj.Sources.IndexOf(fname);
    if i <> -1 then
      proj.Sources.Delete(i);
  end;

  fname := '';
  for i := 0 to proj.sourcesCount-1 do
    if not proj.sourceAbsolute(i).fileExists then
      fname += LineEnding + '    "' + proj.sourceAbsolute(i) + '" ';

  if fname.isNotEmpty and (dlgOkCancel('Other source(s) not found: ' + LineEnding
    + fname + LineEnding + LineEnding + 'Remove all invalid files ?') = mrOK) then
  begin
    for j := proj.sourcesCount-1 downto 0 do
      if not proj.sourceAbsolute(j).fileExists then
        proj.Sources.Delete(j);
  end;

  proj.endUpdate;
end;

procedure TProjectInspectWidget.FormDropFiles(Sender: TObject; const fnames: array of String);
var
  fname, direntry: string;
  lst: TStringList;
  proj: TNativeProject;
procedure addFile(const value: string);
var
  ext: string;
begin
  ext := value.extractFileExt;
  if not isDlangCompilable(ext) then
    exit;
  proj.addSource(value);
  if isEditable(ext) then
    getMultiDocHandler.openDocument(value);
end;
begin
  if fProj.isNotAssigned or (fProj.getFormat = pfDUB) then
    exit;

  proj := TNativeProject(fProj.getProject);
  lst := TStringList.Create;
  proj.beginUpdate;
  try for fname in fnames do
    if fname.fileExists then
      addFile(fname)
    else if fname.dirExists then
    begin
      lst.Clear;
      listFiles(lst, fname, true);
      for direntry in lst do
        addFile(dirEntry);
    end;
  finally
    proj.endUpdate;
    lst.Free;
  end;
end;

procedure TProjectInspectWidget.selConfChange(Sender: TObject);
begin
  if fProj.isNotAssigned or selConf.ItemIndex.equals(-1) or selConf.Items.Count.equals(0) then
    exit;
  fProj.setActiveConfigurationIndex(selConf.ItemIndex);
end;

procedure TProjectInspectWidget.toolbarResize(Sender: TObject);
begin
  TreeFilterEdit1.Width := toolbar.Width - TreeFilterEdit1.Left - TreeFilterEdit1.BorderSpacing.Around;
end;

procedure TProjectInspectWidget.updateDelayed;
begin
  updateImperative;
end;

procedure TProjectInspectWidget.updateImperative;
var
  conf: string;
  itm: TTreeNode;
  chd: TTreeNode;
  i,j: integer;
  sel: string = '';
  fld: string;
  rng: TStringRange = (ptr:nil; pos:0; len:0);
begin
  if Tree.Selected.isAssigned then
    sel := Tree.Selected.GetTextPath;
  fFileNode.DeleteChildren;

  if fProj.isNotAssigned then
    exit;

  Tree.BeginUpdate;

  if not fFileListAsTree then
    for i := 0 to fProj.sourcesCount-1 do
  begin
    itm := Tree.Items.AddChild(fFileNode, fProj.sourceRelative(i));
    itm.Data:= NewStr(fProj.sourceAbsolute(i));
    itm.ImageIndex := 2;
    itm.SelectedIndex := 2;
  end
  else
  // first pass only creates the folders so that they're shown on top
  for j := 0 to 1 do
    for i := 0 to fProj.sourcesCount-1 do
  begin
    fld := '';
    rng.init(fProj.sourceRelative(i));
    itm := fFileNode;
    while not rng.empty do
    begin
      chd := nil;
      fld := rng.takeUntil(['/','\']).yield;
      chd := itm.FindNode(fld);
      if chd.isNotAssigned and ((rng.empty and j.equals(1)) or (not rng.empty and j.equals(0))) then
        chd := Tree.Items.AddChild(itm, fld);
      if chd.isAssigned then
        itm := chd;
      // reached fname
      if rng.empty and j.equals(1) then
      begin
        itm.Data:= NewStr(fProj.sourceAbsolute(i));
        itm.ImageIndex := 2;
        itm.SelectedIndex := 2;
      end
      // next folder or fname
      else
      begin
        rng.popWhile(['/','\']);
        itm.ImageIndex := 5;
        itm.SelectedIndex := 5;
      end;
    end;
  end;
  Tree.EndUpdate;

  selConf.Items.BeginUpdate();
  j := fProj.getActiveConfigurationIndex;
  selConf.Items.Clear;
  for i := 0 to fProj.configurationCount-1 do
    selConf.Items.Add(fProj.configurationName(i));
  selConf.ItemIndex := j;
  selConf.Items.EndUpdate();
end;
{$ENDREGION --------------------------------------------------------------------}

end.
