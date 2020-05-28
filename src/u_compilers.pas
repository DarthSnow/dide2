unit u_compilers;

{$I u_defines.inc}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls,
  u_dcd, u_common, u_interfaces, u_observer, u_writableComponent,
  u_dialogs;

type

  TCompilersPaths = class(TWritableLfmTextComponent)
  strict private
    fPathsForCompletion: DCompiler;
    fDmdExeName: string;
    fDmdRuntimePath: string;
    fDmdPhobosPath: string;
    fGdcExeName: string;
    fGdcRuntimePath: string;
    fGdcPhobosPath: string;
    fLdcExeName: string;
    fLdcRuntimePath: string;
    fLdcPhobosPath: string;
    fUser1ExeName: string;
    fUser1RuntimePath: string;
    fUser1PhobosPath: string;
    fUser2ExeName: string;
    fUser2RuntimePath: string;
    fUser2PhobosPath: string;
    fModified: boolean;
    fWouldNeedRestart: boolean;
    fDefinedAsGlobal: DCompiler;
    procedure setDefinedAsGlobal(value: DCompiler);
    procedure setPathsForCompletion(value: DCompiler);
    procedure setDmdExeName(const value: string);
    procedure setDmdRuntimePath(const value: string);
    procedure setDmdPhobosPath(const value: string);
    procedure setGdcExeName(const value: string);
    procedure setGdcRuntimePath(const value: string);
    procedure setGdcPhobosPath(const value: string);
    procedure setLdcExeName(const value: string);
    procedure setLdcRuntimePath(const value: string);
    procedure setLdcPhobosPath(const value: string);
    procedure setUser1ExeName(const value: string);
    procedure setUser1RuntimePath(const value: string);
    procedure setUser1PhobosPath(const value: string);
    procedure setUser2ExeName(const value: string);
    procedure setUser2RuntimePath(const value: string);
    procedure setUser2PhobosPath(const value: string);
  private
    procedure checkIfGlobalIsGlobal;
  protected
    procedure afterLoad; override;
  published
    property definedAsGlobal: DCompiler read fDefinedAsGlobal write setDefinedAsGlobal;
    property pathsForCompletion: DCompiler read fPathsForCompletion write setPathsForCompletion;
    property DmdExeName: string read fDmdExeName write setDmdExeName;
    property DmdRuntimePath: string read fDmdRuntimePath write setDmdRuntimePath;
    property DmdPhobosPath: string read fDmdPhobosPath write setDmdPhobosPath;
    property GdcExeName: string read fGdcExeName write setGdcExeName;
    property GdcRuntimePath: string read fGdcRuntimePath write setGdcRuntimePath;
    property GdcPhobosPath: string read fGdcPhobosPath write setGdcPhobosPath;
    property LdcExeName: string read fLdcExeName write setLdcExeName;
    property LdcRuntimePath: string read fLdcRuntimePath write setLdcRuntimePath;
    property LdcPhobosPath: string read fLdcPhobosPath write setLdcPhobosPath;
    property User1ExeName: string read fUser1ExeName write setUser1ExeName;
    property User1RuntimePath: string read fUser1RuntimePath write setUser1RuntimePath;
    property User1PhobosPath: string read fUser1PhobosPath write setUser1PhobosPath;
    property User2ExeName: string read fUser2ExeName write setUser2ExeName;
    property User2RuntimePath: string read fUser2RuntimePath write setUser2RuntimePath;
    property User2PhobosPath: string read fUser2PhobosPath write setUser2PhobosPath;
  public
    procedure assign(source: TPersistent); override;
    property wouldNeedRestart: boolean read fWouldNeedRestart write fWouldNeedRestart;
    property modified: boolean read fModified write fModified;
  end;

  { TCompilersPathsEditor }

  TCompilersPathsEditor = class(TForm, IEditableOptions, ICompilerSelector, IProjectObserver)
    GroupBox7: TGroupBox;
    selDefault: TComboBox;
    selGlobal: TComboBox;
    selDMDrt: TDirectoryEdit;
    selUSER2std: TDirectoryEdit;
    selDMDstd: TDirectoryEdit;
    selGDCrt: TDirectoryEdit;
    selGDCstd: TDirectoryEdit;
    selLDCrt: TDirectoryEdit;
    selLDCstd: TDirectoryEdit;
    selUSER1rt: TDirectoryEdit;
    selUSER1std: TDirectoryEdit;
    selUSER2rt: TDirectoryEdit;
    selDMDexe: TFileNameEdit;
    selGDCexe: TFileNameEdit;
    selLDCexe: TFileNameEdit;
    selUSER1exe: TFileNameEdit;
    selUSER2exe: TFileNameEdit;
    grpDMD: TGroupBox;
    grpGDC: TGroupBox;
    grpLDC: TGroupBox;
    grpUSER1: TGroupBox;
    grpUSER2: TGroupBox;
    GroupBox6: TGroupBox;
    ScrollBox1: TScrollBox;
    StaticText1: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText13: TStaticText;
    StaticText14: TStaticText;
    StaticText15: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    procedure dialogOpen(sender: TObject);
  strict private
    fPaths: TCompilersPaths;
    fPathsBackup: TCompilersPaths;
    fProj: ICommonProject;
    procedure tryLdcImportFromLdcExeName();
    procedure editedExe(sender: TObject);
    procedure editedRt(sender: TObject);
    procedure editedStd(sender: TObject);
    procedure selectedExe(sender: TObject; var value: string);
    procedure selectedRt(sender: TObject; var value: string);
    procedure selectedStd(sender: TObject; var value: string);
    procedure selectedDefault(sender: TObject);
    procedure selectedGlobal(sender: TObject);
    procedure autoDetectDMD;
    procedure autoDetectGDC;
    procedure autoDetectLDC;
    procedure dataToGui;
    //
    function optionedWantCategory(): string;
    function optionedWantEditorKind: TOptionEditorKind;
    function optionedWantContainer: TPersistent;
    procedure optionedEvent(event: TOptionEditorEvent);
    function optionedOptionsModified: boolean;
    //
    function singleServiceName: string;
    function isCompilerValid(value: DCompiler): boolean;
    function getCompilerPath(value: DCompiler; translateToWrapper: boolean): string;
    procedure getCompilerImports(value: DCompiler; paths: TStrings);
    //
    procedure projNew(project: ICommonProject);
    procedure projChanged(project: ICommonProject);
    procedure projClosing(project: ICommonProject);
    procedure projFocused(project: ICommonProject);
    procedure projCompiling(project: ICommonProject);
    procedure projCompiled(project: ICommonProject; success: boolean);
    procedure updateDCD;
  public
    constructor create(aOwner: TComponent); override;
    destructor destroy; override;
  end;

//var
// globalCompiler: DCompiler;

implementation
{$R *.lfm}

uses
  u_libman;

var
  CompilersPathsEditor: TCompilersPathsEditor;

const
  optFname = 'compilerspaths.txt';

{$REGION Standard Object/Components things -------------------------------------}
constructor TCompilersPathsEditor.create(aOwner: TComponent);
var
  fname: string;
  dcomp: DCompiler;
begin
  inherited;

  selDefault.Items.BeginUpdate;
  selGlobal.Items.BeginUpdate;
  try for dcomp in DCompiler do
  begin
    case dcomp of
      dmd:
      begin
        selDefault.Items.Add('DMD');
        selGlobal.Items.Add('DMD');
      end;
      gdc:
      begin
        selDefault.Items.Add('GDC');
        selGlobal.Items.Add('GDC');
      end;
      gdmd:
      begin
        selDefault.Items.Add('GDMD (same paths as GDC)');
        selGlobal.Items.Add('GDMD (same paths as GDC)');
      end;
      ldc:
      begin
        selDefault.Items.Add('LDC');
        selGlobal.Items.Add('LDC');
      end;
      ldmd:
      begin
        selDefault.Items.Add('LDMD (same paths as LDC)');
        selGlobal.Items.Add('LDMD (same paths as LDC)');
      end;
      user1:
      begin
        selDefault.Items.Add('USER1');
        selGlobal.Items.Add('USER1');
      end;
      user2:
      begin
        selDefault.Items.Add('USER2');
        selGlobal.Items.Add('USER2');
      end;
      global:
      begin
        selDefault.Items.Add('GLOBAL (as defined in the options)');
        // 'global' must be everything but 'global'
        selGlobal.Items.Add('<N/A>');
      end;
      else raise Exception.create('missing DCompiler value in a case of');
    end;
  end;
  finally
    selDefault.Items.EndUpdate;
    selGlobal.Items.EndUpdate;
  end;

  fPaths:= TCompilersPaths.Create(self);
  fPathsBackup:= TCompilersPaths.Create(self);

  fname := getDocPath + optFname;
  if fname.fileExists then
    fPaths.loadFromFile(fname);
  if not isCompilerValid(dmd) then
    autoDetectDMD;
  if not isCompilerValid(gdc) then
    autoDetectGDC;

  // #148 / #210
  // if not isCompilerValid(ldc) then
  //  autoDetectLDC;
  fPathsBackup.Assign(fPaths);
  dataToGui;

  updateDCD;

  selDMDexe.OnAcceptFileName:= @selectedExe;
  selGDCexe.OnAcceptFileName:= @selectedExe;
  selLDCexe.OnAcceptFileName:= @selectedExe;
  selUSER1exe.OnAcceptFileName:= @selectedExe;
  selUSER2exe.OnAcceptFileName:= @selectedExe;
  selDMDexe.OnEditingDone:= @editedExe;
  selGDCexe.OnEditingDone:= @editedExe;
  selLDCexe.OnEditingDone:= @editedExe;
  selUSER1exe.OnEditingDone:= @editedExe;
  selUSER2exe.OnEditingDone:= @editedExe;

  selDMDrt.OnAcceptDirectory:= @selectedRt;
  selGDCrt.OnAcceptDirectory:= @selectedRt;
  selLDCrt.OnAcceptDirectory:= @selectedRt;
  selUSER1rt.OnAcceptDirectory:= @selectedRt;
  selUSER2rt.OnAcceptDirectory:= @selectedRt;
  selDMDrt.OnEditingDone:= @editedRt;
  selGDCrt.OnEditingDone:= @editedRt;
  selLDCrt.OnEditingDone:= @editedRt;
  selUSER1rt.OnEditingDone:= @editedRt;
  selUSER2rt.OnEditingDone:= @editedRt;

  selDMDstd.OnAcceptDirectory:= @selectedStd;
  selGDCstd.OnAcceptDirectory:= @selectedStd;
  selLDCstd.OnAcceptDirectory:= @selectedStd;
  selUSER1std.OnAcceptDirectory:= @selectedStd;
  selUSER2std.OnAcceptDirectory:= @selectedStd;
  selDMDstd.OnEditingDone:= @editedStd;
  selGDCstd.OnEditingDone:= @editedStd;
  selLDCstd.OnEditingDone:= @editedStd;
  selUSER1std.OnEditingDone:= @editedStd;
  selUSER2std.OnEditingDone:= @editedStd;

  selDefault.OnSelect:= @selectedDefault;
  selGlobal.OnSelect:= @selectedGlobal;

  EntitiesConnector.addSingleService(self);
  EntitiesConnector.addObserver(self);
end;

destructor TCompilersPathsEditor.destroy;
begin
  fPaths.saveToFile(getDocPath + optFname);
  EntitiesConnector.removeObserver(self);
  inherited;
end;

procedure TCompilersPaths.checkIfGlobalIsGlobal;
begin
  if fDefinedAsGlobal = DCompiler.global then
  begin
    fDefinedAsGlobal := low(DCompiler);
    raise Exception.Create('global compiler should not be set to DCompiler.global');
  end;
end;

procedure TCompilersPaths.assign(source: TPersistent);
var
  src: TCompilersPaths;
begin
  if source is TCompilersPaths then
  begin
    src := TCompilersPaths(source);
    pathsForCompletion  := src.fPathsForCompletion;
    DmdExeName       := src.fDmdExeName;
    DmdRuntimePath   := src.fDmdRuntimePath;
    DmdPhobosPath    := src.fDmdPhobosPath;
    GdcExeName       := src.fGdcExeName;
    GdcRuntimePath   := src.fGdcRuntimePath;
    GdcPhobosPath    := src.fGdcPhobosPath;
    LdcExeName       := src.fLdcExeName;
    LdcRuntimePath   := src.fLdcRuntimePath;
    LdcPhobosPath    := src.fLdcPhobosPath;
    User1ExeName     := src.fUser1ExeName;
    User1RuntimePath := src.fUser1RuntimePath;
    User1PhobosPath  := src.fUser1PhobosPath;
    User2ExeName     := src.fUser2ExeName;
    User2RuntimePath := src.fUser2RuntimePath;
    User2PhobosPath  := src.fUser2PhobosPath;
  end
  else inherited;
end;

procedure TCompilersPaths.setPathsForCompletion(value: Dcompiler);
begin
  if fPathsForCompletion = value then
    exit;
  fPathsForCompletion:=value;
  fWouldNeedRestart := true;
  fModified:=true;
end;

procedure TCompilersPaths.setDefinedAsGlobal(value: DCompiler);
begin
  if value = DCompiler.global then
    value := low(DCompiler);
  fDefinedAsGlobal := value;
end;

procedure TCompilersPaths.setDmdExeName(const value: string);
begin
  if fDmdExeName = value then
    exit;
  fDmdExeName:=value;
  fModified:=true;
end;

procedure TCompilersPaths.setDmdRuntimePath(const value: string);
begin
  if fDmdRuntimePath = value then
    exit;
  fDmdRuntimePath:=value;
  fModified:=true;
  if fPathsForCompletion = dmd then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setDmdPhobosPath(const value: string);
begin
  if fDmdPhobosPath = value then
    exit;
  fDmdPhobosPath:=value;
  fModified:=true;
  if fPathsForCompletion = dmd then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setGdcExeName(const value: string);
begin
  if fGdcExeName = value then
    exit;
  fGdcExeName:=value;
  fModified:=true;
end;

procedure TCompilersPaths.setGdcRuntimePath(const value: string);
begin
  if fGdcRuntimePath = value then
    exit;
  fGdcRuntimePath:=value;
  fModified:=true;
  if fPathsForCompletion in [gdc,gdmd] then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setGdcPhobosPath(const value: string);
begin
  if fGdcPhobosPath = value then
    exit;
  fGdcPhobosPath:=value;
  fModified:=true;
  if fPathsForCompletion in [gdc,gdmd] then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setLdcExeName(const value: string);
begin
  if fLdcExeName = value then
    exit;
  fLdcExeName:=value;
  fModified:=true;
end;

procedure TCompilersPaths.setLdcRuntimePath(const value: string);
begin
  if fLdcRuntimePath = value then
    exit;
  fLdcRuntimePath:=value;
  fModified:=true;
  if fPathsForCompletion in [ldc,ldmd] then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setLdcPhobosPath(const value: string);
begin
  if fLdcPhobosPath = value then
    exit;
  fLdcPhobosPath:=value;
  fModified:=true;
  if fPathsForCompletion in [ldc,ldmd] then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setUser1ExeName(const value: string);
begin
  if fUser1ExeName = value then
    exit;
  fUser1ExeName:=value;
  fModified:=true;
end;

procedure TCompilersPaths.setUser1RuntimePath(const value: string);
begin
  if fUser1RuntimePath = value then
    exit;
  fUser1RuntimePath:=value;
  fModified:=true;
  if fPathsForCompletion = user1 then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setUser1PhobosPath(const value: string);
begin
  if fUser1PhobosPath = value then
    exit;
  fUser1PhobosPath:=value;
  fModified:=true;
  if fPathsForCompletion = user1 then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setUser2ExeName(const value: string);
begin
  if fUser2ExeName = value then
    exit;
  fUser2ExeName:=value;
  fModified:=true;
end;

procedure TCompilersPaths.setUser2RuntimePath(const value: string);
begin
  if fUser2RuntimePath = value then
    exit;
  fUser2RuntimePath:=value;
  fModified:=true;
  if fPathsForCompletion = user2 then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.setUser2PhobosPath(const value: string);
begin
  if fUser2PhobosPath = value then
    exit;
  fUser2PhobosPath:=value;
  fModified:=true;
  if fPathsForCompletion = user2 then
    fWouldNeedRestart := true;
end;

procedure TCompilersPaths.afterLoad;
begin
  inherited;
  fModified:=false;
  fWouldNeedRestart:=false;
end;
{$ENDREGION}

{$REGION IProjectObserver ----------------------------------------------------}
procedure TCompilersPathsEditor.projNew(project: ICommonProject);
begin
end;

procedure TCompilersPathsEditor.projChanged(project: ICommonProject);
begin
end;

procedure TCompilersPathsEditor.projClosing(project: ICommonProject);
begin
  if fProj = project then
    fProj := nil;
end;

procedure TCompilersPathsEditor.projFocused(project: ICommonProject);
begin
  fProj := project;
end;

procedure TCompilersPathsEditor.projCompiling(project: ICommonProject);
begin
end;

procedure TCompilersPathsEditor.projCompiled(project: ICommonProject; success: boolean);
begin
end;
{$ENDREGION}

{$REGION IEditableOptions ----------------------------------------------------}
function TCompilersPathsEditor.optionedWantCategory(): string;
begin
  exit('Compilers paths');
end;

function TCompilersPathsEditor.optionedWantEditorKind: TOptionEditorKind;
begin
  exit(oekForm);
end;

function TCompilersPathsEditor.optionedWantContainer: TPersistent;
begin
  fPathsBackup.assign(fPaths);
  exit(self);
end;

procedure TCompilersPathsEditor.optionedEvent(event: TOptionEditorEvent);
begin
  case event of
    oeeAccept:
    begin
      fPathsBackup.assign(fPaths);
      if fPaths.wouldNeedRestart and fPaths.modified then
      begin
        if not DCDWrapper.launchedByCe then
          dlgOkInfo('Dexed and DCD must be restarted manually in order to cache'
            + ' the right runtime and the standard library versions.')
        else
        begin
          DCDWrapper.relaunch;
          updateDCD;
          LibMan.updateDCD;
          if assigned(fProj) then
            fProj.activate;
        end;
      end;
      fPaths.modified:=false;
      fPaths.wouldNeedRestart:=false;
    end;
    oeeCancel:
    begin
      fPaths.assign(fPathsBackup);
      fPaths.modified:=false;
      fPaths.wouldNeedRestart:=false;
    end;
  end;
end;

function TCompilersPathsEditor.optionedOptionsModified: boolean;
begin
  exit(fPaths.modified);
end;
{$ENDREGION}

{$REGION ICompilerSelector ---------------------------------------------------}
function TCompilersPathsEditor.singleServiceName: string;
begin
  exit('ICompilerSelector');
end;

function TCompilersPathsEditor.isCompilerValid(value: DCompiler): boolean;
begin
  result := false;
  with fPaths do case value of
    DCompiler.dmd: exit(DmdExeName.fileExists);
    DCompiler.gdc: exit(GdcExeName.fileExists);
    DCompiler.gdmd: exit(exeFullName('gdmd' + exeExt).fileExists);
    DCompiler.ldc: exit(LdcExeName.fileExists);
    DCompiler.ldmd: exit(exeFullName('ldmd2' + exeExt).fileExists);
    DCompiler.user1: exit(User1ExeName.fileExists);
    DCompiler.user2: exit(User2ExeName.fileExists);
    DCompiler.global:
    begin
      fPaths.checkIfGlobalIsGlobal;
      exit(isCompilerValid(fPaths.definedAsGlobal));
    end;
  end;
end;

function TCompilersPathsEditor.getCompilerPath(value: DCompiler; translateToWrapper: boolean): string;
begin
  result := '';
  with fPaths do case value of
    DCompiler.dmd: exit(DmdExeName);
    DCompiler.gdc: if not translateToWrapper then exit(GdcExeName) else exit(exeFullName('gdmd' + exeExt));
    DCompiler.gdmd: exit(exeFullName('gdmd' + exeExt));
    DCompiler.ldc: if not translateToWrapper then exit(LdcExeName) else exit(exeFullName('ldmd2' + exeExt));
    DCompiler.ldmd: exit(exeFullName('ldmd2' + exeExt));
    DCompiler.user1: exit(User1ExeName);
    DCompiler.user2: exit(User2ExeName);
    DCompiler.global:
    begin
      checkIfGlobalIsGlobal;
      exit(getCompilerPath(fPaths.definedAsGlobal, translateToWrapper));
    end;
  end;
end;

procedure TCompilersPathsEditor.getCompilerImports(value: DCompiler; paths: TStrings);
  procedure tryAdd(const pth: string);
  begin
    if pth.isNotEmpty then
      paths.Add(pth);
  end;
begin
  with fPaths do case value of
    DCompiler.dmd: begin tryAdd(DmdRuntimePath); tryAdd(DmdPhobosPath); end;
    DCompiler.gdc, DCompiler.gdmd:
      begin tryAdd(GdcRuntimePath); tryAdd(GdcPhobosPath); end;
    DCompiler.ldc, DCompiler.ldmd:
      begin tryAdd(LdcRuntimePath); tryAdd(LdcPhobosPath); end;
    DCompiler.user1:
      begin tryAdd(User1RuntimePath); tryAdd(User1PhobosPath); end;
    DCompiler.user2:
      begin tryAdd(User2RuntimePath); tryAdd(User2PhobosPath); end;
    DCompiler.global:
      begin checkIfGlobalIsGlobal; getCompilerImports(fPaths.definedAsGlobal, paths); end;
  end;
end;
{$ENDREGION}

{$REGION Compilers paths things ------------------------------------------------}
procedure TCompilersPathsEditor.updateDCD;
var
  imprt: TStringList;
begin
  imprt := TStringList.Create;
  try
    getCompilerImports(fPaths.pathsForCompletion, imprt);
    DcdWrapper.addImportFolders(imprt);
  finally
    imprt.free;
  end;
end;

procedure TCompilersPathsEditor.dataToGui;
begin
  with fPaths do
  begin
    selDMDexe.FileName  := DmdExeName;
    selDMDrt.Directory  := DmdRuntimePath;
    selDMDstd.Directory := DmdPhobosPath;

    selGDCexe.FileName  := GdcExeName;
    selGDCrt.Directory  := GdcRuntimePath;
    selGDCstd.Directory := GdcPhobosPath;

    selLDCexe.FileName  := LdcExeName;
    selLDCrt.Directory  := LdcRuntimePath;
    selLDCstd.Directory := LdcPhobosPath;

    selUSER1exe.FileName  := User1ExeName;
    selUSER1rt.Directory  := User1RuntimePath;
    selUSER1std.Directory := User1PhobosPath;

    selUSER2exe.FileName  := User2ExeName;
    selUSER2rt.Directory  := User2RuntimePath;
    selUSER2std.Directory := User2PhobosPath;

    selDefault.ItemIndex := integer(pathsForCompletion);
    selGlobal.ItemIndex  := integer(definedAsGlobal);
  end;
end;

procedure TCompilersPathsEditor.dialogOpen(sender: TObject);
var
  fne: TFileNameEdit;
  dre: TDirectoryEdit;
begin
  if sender is TFileNameEdit then
  begin
    fne := TFileNameEdit(sender);
    fne.InitialDir:=fne.FileName.extractFileDir;
    fne.DialogTitle:='Select a D compiler';
  end
  else
  begin
    dre := TDirectoryEdit(sender);
    dre.RootDir:=dre.Directory;
    dre.ShowHidden:=true;
    dre.DialogTitle:='Select a library path';
  end;
end;

procedure TCompilersPathsEditor.tryLdcImportFromLdcExeName();
var
  d: string;
  i: string;
begin
  if not fPaths.LdcExeName.fileExists then
    exit;
  d := fPaths.LdcExeName.extractFileDir.extractFileDir;
  i := d + DirectorySeparator + 'import';
  if (i + DirectorySeparator + 'object.d').fileExists and
    selLDCrt.Directory.isEmpty then
  begin
    selLDCrt.Directory := i;
    fPaths.LdcRuntimePath := i;
  end;
end;

procedure TCompilersPathsEditor.selectedExe(sender: TObject; var value: string);
var
  ctrl: TWinControl;
begin
  ctrl := TWinControl(sender);
  if ctrl.Parent = grpDMD then
    fPaths.DmdExeName:=value
  else if ctrl.Parent = grpGDC then
    fPaths.GDCExeName:=value
  else if ctrl.Parent = grpLDC then
    fPaths.LdcExeName:=value
  else if ctrl.Parent = grpUSER1 then
    fPaths.User1ExeName:=value
  else if ctrl.Parent = grpUSER2 then
    fPaths.User2ExeName:=value;
end;

procedure TCompilersPathsEditor.editedExe(sender: TObject);
var
  ctrl: TWinControl;
begin
  ctrl := TWinControl(sender);
  if ctrl.Parent = grpDMD then
    fPaths.DmdExeName:=selDMDexe.FileName
  else if ctrl.Parent = grpGDC then
    fPaths.GDCExeName:=selGDCexe.FileName
  else if ctrl.Parent = grpLDC then
  begin
    fPaths.LdcExeName:=selLDCexe.FileName;
    tryLdcImportFromLdcExeName;
  end
  else if ctrl.Parent = grpUSER1 then
    fPaths.User1ExeName:=selUSER1exe.FileName
  else if ctrl.Parent = grpUSER2 then
    fPaths.User2ExeName:=selUSER2exe.FileName;
end;

procedure TCompilersPathsEditor.selectedRt(sender: TObject; var value: string);
var
  ctrl: TWinControl;
begin
  ctrl := TWinControl(sender);
  if ctrl.Parent = grpDMD then
    fPaths.DmdRuntimePath:=value
  else if ctrl.Parent = grpGDC then
    fPaths.GDCRuntimePath:=value
  else if ctrl.Parent = grpLDC then
    fPaths.LdcRuntimePath:=value
  else if ctrl.Parent = grpUSER1 then
    fPaths.User1RuntimePath:=value
  else if ctrl.Parent = grpUSER2 then
    fPaths.User2RuntimePath:=value;
end;

procedure TCompilersPathsEditor.editedRt(sender: TObject);
var
  ctrl: TWinControl;
begin
  ctrl := TWinControl(sender);
  if ctrl.Parent = grpDMD then
    fPaths.DmdRuntimePath:=selDMDrt.Directory
  else if ctrl.Parent = grpGDC then
    fPaths.GDCRuntimePath:=selGDCrt.Directory
  else if ctrl.Parent = grpLDC then
    fPaths.LdcRuntimePath:=selLDCrt.Directory
  else if ctrl.Parent = grpUSER1 then
    fPaths.User1RuntimePath:=selUSER1rt.Directory
  else if ctrl.Parent = grpUSER2 then
    fPaths.User2RuntimePath:=selUSER2rt.Directory;
end;

procedure TCompilersPathsEditor.selectedStd(sender: TObject; var value: string);
var
  ctrl: TWinControl;
begin
  ctrl := TWinControl(sender);
  if ctrl.Parent = grpDMD then
    fPaths.DmdPhobosPath:=value
  else if ctrl.Parent = grpGDC then
    fPaths.GDCPhobosPath:=value
  else if ctrl.Parent = grpLDC then
    fPaths.LdcPhobosPath:=value
  else if ctrl.Parent = grpUSER1 then
    fPaths.User1PhobosPath:=value
  else if ctrl.Parent = grpUSER2 then
    fPaths.User2PhobosPath:=value;
end;

procedure TCompilersPathsEditor.editedStd(sender: TObject);
var
  ctrl: TWinControl;
begin
  ctrl := TWinControl(sender);
  if ctrl.Parent = grpDMD then
    fPaths.DmdPhobosPath:=selDMDstd.Directory
  else if ctrl.Parent = grpGDC then
    fPaths.GDCPhobosPath:=selGDCstd.Directory
  else if ctrl.Parent = grpLDC then
    fPaths.LdcPhobosPath:=selLDCstd.Directory
  else if ctrl.Parent = grpUSER1 then
    fPaths.User1PhobosPath:=selUSER1std.Directory
  else if ctrl.Parent = grpUSER2 then
    fPaths.User2PhobosPath:=selUSER2std.Directory;
end;

procedure TCompilersPathsEditor.selectedDefault(sender: TObject);
begin
  fPaths.pathsForCompletion:= DCompiler(selDefault.ItemIndex);
end;

procedure TCompilersPathsEditor.selectedGlobal(sender: TObject);
var
  v: DCompiler;
begin
  v := DCompiler(selGlobal.ItemIndex);
  if v = DCompiler.global then
    v := DCompiler.dmd;
  fPaths.definedAsGlobal := v;
end;

procedure TCompilersPathsEditor.autoDetectDMD;
{$IFDEF WINDOWS}
var
  path: string;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  path := exeFullName('dmd' + exeExt);
  if path.fileExists then
  begin
    fPaths.DmdExeName:= path;
    path := path.extractFileDir.extractFileDir.extractFileDir;
    if (path + '\src\druntime\import').dirExists then
      fPaths.DmdRuntimePath := path + '\src\druntime\import';
    if (path + '\src\phobos').dirExists then
      fPaths.DmdPhobosPath := path + '\src\phobos';
  end;
  {$ENDIF}
  {$IFDEF LINUX}
  if '/usr/bin/dmd'.fileExists then
    fPaths.DmdExeName:='/usr/bin/dmd';
  if '/usr/include/dmd/druntime/import'.dirExists then
    fPaths.DmdRuntimePath:='/usr/include/dmd/druntime/import';
  if '/usr/include/dmd/phobos'.dirExists then
    fPaths.DmdPhobosPath:='/usr/include/dmd/phobos';
  {$ENDIF}
  {$IFDEF BSD}
  if '%%LOCALBASE%%/bin/dmd'.fileExists then
    fPaths.DmdExeName:='%%LOCALBASE%%/bin/dmd';
  if '%%LOCALBASE%%/include/dmd/druntime/import'.dirExists then
    fPaths.DmdRuntimePath:='%%LOCALBASE%%/include/dmd/druntime/import';
  if '%%LOCALBASE%%/include/dmd/phobos'.dirExists then
    fPaths.DmdPhobosPath:='%%LOCALBASE%%/include/dmd/phobos';
  {$ENDIF}
  {$IFDEF DARWIN}
  if '/usr/local/bin/dmd'.fileExists then
    fPaths.DmdExeName:='/usr/local/bin/dmd';
  if '/Library/D/dmd/src/druntime/import'.dirExists then
    fPaths.DmdRuntimePath:='/Library/D/dmd/src/druntime/import';
  if '/Library/D/dmd/src/phobos'.dirExists then
    fPaths.DmdPhobosPath:='/Library/D/dmd/src/phobos';
  {$ENDIF}
end;

procedure TCompilersPathsEditor.autoDetectGDC;
begin
  {$IFDEF LINUX}
  if '/usr/bin/gdc'.fileExists then
    fPaths.GdcExeName:='/usr/bin/dmd';
  // redhat
  if '/usr/lib/gcc/x86_64-redhat-linux/9/include/d'.dirExists then
    fPaths.GdcRuntimePath:='/usr/lib/gcc/x86_64-redhat-linux/9/include/d'
  else if '/usr/lib/gcc/x86_64-redhat-linux/10/include/d'.dirExists then
    fPaths.GdcRuntimePath:='/usr/lib/gcc/x86_64-redhat-linux/10/include/d'
  // debian
  else if '/usr/lib/gcc/x86_64-linux-gnu/9/include/d'.dirExists then
    fPaths.GdcRuntimePath:='/usr/lib/gcc/x86_64-linux-gnu/9/include/d'
  else if '/usr/lib/gcc/x86_64-linux-gnu/10/include/d'.dirExists then
    fPaths.GdcRuntimePath:='/usr/lib/gcc/x86_64-linux-gnu/10/include/d'
  // arch
  else if 'usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/include/d'.dirExists then
    fPaths.GdcRuntimePath:='usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/include/d';
  {$ENDIF}
end;

procedure TCompilersPathsEditor.autoDetectLDC;
var
  i: integer;
  path: string;
  str: TStringList;
begin
  path := exeFullName('ldc2' + exeExt);
  if path.fileExists then
  begin
    fPaths.LdcExeName:= path;
    str := TStringList.Create;
    try
      path := path.extractFileDir.extractFilePath;
      FindAllDirectories(str, path, true);
      for path in str do
      begin
        i := pos('import' + DirectorySeparator + 'ldc', path);
        if i > 0 then
        begin
          fPaths.LdcRuntimePath:= path[1..i + 5];
          break;
        end;
      end;
    finally
      str.Free;
    end;
  end;
end;
{$ENDREGION}

initialization
  CompilersPathsEditor := TCompilersPathsEditor.create(nil);
finalization
  CompilersPathsEditor.free;
end.

