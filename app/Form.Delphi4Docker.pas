unit Form.Delphi4Docker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.ListBox, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts,
  FMX.TabControl, System.Zip, System.Actions, FMX.ActnList,
  System.Threading, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.StorageJSON,
  Socket.Data.Frame;

type
  TDelphi4Docker = class(TForm)
    tcPackUnpack: TTabControl;
    tiPack: TTabItem;
    tiUnpack: TTabItem;
    fdmtDefs: TFDMemTable;
    fdmtDefsuser_name: TStringField;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    Layout1: TLayout;
    Label1: TLabel;
    edtEmbtFolder: TEdit;
    SearchEditButton1: TSearchEditButton;
    ProgressBar1: TProgressBar;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Layout6: TLayout;
    Layout7: TLayout;
    Label2: TLabel;
    edtAppDataRoamingFolder: TEdit;
    SearchEditButton2: TSearchEditButton;
    ProgressBar2: TProgressBar;
    Label3: TLabel;
    edtProgramDataFolder: TEdit;
    SearchEditButton3: TSearchEditButton;
    ProgressBar3: TProgressBar;
    Label8: TLabel;
    edtPublicDocumentsFolder: TEdit;
    SearchEditButton5: TSearchEditButton;
    ProgressBar5: TProgressBar;
    Label9: TLabel;
    edtUserDocumentsFolder: TEdit;
    SearchEditButton6: TSearchEditButton;
    ProgressBar6: TProgressBar;
    Label4: TLabel;
    edtEclipseAdoptiumFolder: TEdit;
    SearchEditButton4: TSearchEditButton;
    ProgressBar4: TProgressBar;
    Layout8: TLayout;
    Label10: TLabel;
    edtEmbarcaderoDestFolder: TEdit;
    SearchEditButton7: TSearchEditButton;
    ProgressBar7: TProgressBar;
    Layout9: TLayout;
    Label11: TLabel;
    edtEmbarcaderoProgramDataDestFolder: TEdit;
    SearchEditButton8: TSearchEditButton;
    ProgressBar8: TProgressBar;
    Layout10: TLayout;
    Layout11: TLayout;
    Label12: TLabel;
    edtEclipseAdoptiumDestFolder: TEdit;
    SearchEditButton9: TSearchEditButton;
    ProgressBar9: TProgressBar;
    Layout12: TLayout;
    Label13: TLabel;
    edtEmbarcaderoUserDocumentsDestFolder: TEdit;
    SearchEditButton10: TSearchEditButton;
    ProgressBar10: TProgressBar;
    Layout13: TLayout;
    Label14: TLabel;
    edtEmbarcaderoPublicDocumentsDestFolder: TEdit;
    SearchEditButton11: TSearchEditButton;
    ProgressBar11: TProgressBar;
    Layout14: TLayout;
    Label15: TLabel;
    edtEmbarcaderoAppDataRoamingDestFolder: TEdit;
    SearchEditButton12: TSearchEditButton;
    ProgressBar12: TProgressBar;
    Layout15: TLayout;
    btnPack: TButton;
    btnCancel: TButton;
    btnSend: TButton;
    lblAddr: TLabel;
    Layout16: TLayout;
    Layout17: TLayout;
    Label7: TLabel;
    edtHostAddr: TEdit;
    Layout18: TLayout;
    Label6: TLabel;
    edtWinePrefix: TEdit;
    Label5: TLabel;
    edtWineUserName: TEdit;
    btnReceive: TButton;
    btnUnpackAndSetup: TButton;
    ProgressBar13: TProgressBar;
    ProgressBar14: TProgressBar;
    Layout19: TLayout;
    Label16: TLabel;
    edtTestProjectsFolder: TEdit;
    SearchEditButton13: TSearchEditButton;
    ProgressBar15: TProgressBar;
    Layout20: TLayout;
    Label17: TLabel;
    edtTestProjectsDestFolder: TEdit;
    SearchEditButton14: TSearchEditButton;
    ProgressBar16: TProgressBar;
    Button1: TButton;
    procedure SearchEditButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnReceiveClick(Sender: TObject);
    procedure btnPackClick(Sender: TObject);
    procedure SearchEditButton2Click(Sender: TObject);
    procedure SearchEditButton3Click(Sender: TObject);
    procedure SearchEditButton4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnUnpackAndSetupClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure SearchEditButton5Click(Sender: TObject);
    procedure SearchEditButton6Click(Sender: TObject);
    procedure edtWinePrefixChange(Sender: TObject);
    procedure edtWineUserNameChange(Sender: TObject);
    procedure SearchEditButton13Click(Sender: TObject);
  private type
    TStatus = (Packing, Unpacking, Sending, Receiving, Cancelled, Error);
    TStatusSet = set of TStatus;
  private
    {$IFDEF SERVER}
    FServer: TSocketDataFrame;
    {$ENDIF SERVER}
    FClient: TSocketDataFrame;
    FTask: ITask;
    FStatus: TStatusSet;
    FPack: TZipFile;
    procedure CreateDefs();
    procedure TryLoadDefs();
    procedure FillForm();
    procedure UpdateComponents();
    procedure CheckPaths;
    procedure PackDirectly;
    procedure UnpackDirectly;
    function UpdateEdit(const AEdit: TEdit;
      const AProc: TProc): ITask;
    //Sockets
    function Connect: boolean;
    procedure Disconnect;
    //Zip
    function ZipEdit(const AArchiveFileName: string; const AEdit: TEdit): ITask;
    procedure ZipDirectoryContents(const ZipFileName: string; const Path: string;
      const AProgressBar: TProgressBar = nil);
    //Unzip
    function UnzipEdit(const AZipFileName, AArchiveFileName: string; const AEdit: TEdit): ITask;
    procedure UnzipFileContents(const ZipFileName, AArchiveFileName: string; const ADestPath: string;
      const AProgressBar: TProgressBar = nil);
    procedure AddToPack(const AFileName: string);
    //Operations
    procedure DoOperation(const AStatus: TStatus; const AProc: TProc);
    procedure DoCancel();
  public
    { Public declarations }
  end;

  TVisualUpdate = class
  public
    class function GetComp(const AClass: TClass; const AControl: TControl): TComponent;
    class procedure UpdateAni(const AEdit: TEdit; const AStatus: boolean);
    class procedure UpdateSearch(const AEdit: TEdit; const AStatus: boolean);
    class function GetProgressBar(const AControl: TPresentedControl): TProgressBar;
  end;

var
  Delphi4Docker: TDelphi4Docker;

implementation

uses
  System.IOUtils, System.SyncObjs, System.Net.Socket, System.Rtti,
  FMX.DialogService,
  Routines.Windows, Common.Paths;

const
  SERVER_PORT = 10031;

{$R *.fmx}

procedure TDelphi4Docker.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FTask) and (FTask.Status = TTaskStatus.Running) then
  begin
    ShowMessage('Work in progress. Hold on!');
    CanClose := false;
  end;
end;

procedure TDelphi4Docker.FormCreate(Sender: TObject);
begin
  FPack := TZipFile.Create();
  FStatus := [];
  UpdateComponents();
  CreateDefs();

  {$IFDEF SERVER}
  tiUnpack.Visible := false;
  tiPack.Visible := true;
  tcPackUnpack.ActiveTab := tiPack;
  FServer := TSocketDataFrame.Create();
  FServer.Listen(TCommonInfo.GetIpAddress(), SERVER_PORT);
  TPathBuilder.Delegator := function: IEnvironmentPath begin
    Result := TLocalEnvironmentPath.Create();
  end;
  {$ENDIF SERVER}

  {$IFDEF CLIENT}
  tiPack.Visible := false;
  tiUnpack.Visible := true;
  tcPackUnpack.ActiveTab := tiUnpack;
  FClient := TSocketDataFrame.Create();
  TPathBuilder.Delegator := function: IEnvironmentPath begin
    Result := TWineHostEnvironmentPath.Create(
      edtWinePrefix.Text, edtWineUserName.Text);
  end;
  {$ENDIF CLIENT}

  FillForm();
  UpdateComponents();
end;

procedure TDelphi4Docker.FormDestroy(Sender: TObject);
begin
  {$IFDEF SERVER}
  try
    FServer.Close();
    FServer.Free;
  except
    //
  end;
  {$ENDIF SERVER}

  {$IFDEF CLIENT}
  FClient.Free;
  {$ENDIF CLIENT}
  FPack.Free();
end;

procedure TDelphi4Docker.FillForm;
begin
  {$IFDEF SERVER}
  edtEmbtFolder.Text := TPathBuilder.Build.EmbarcaderoPath();
  edtAppDataRoamingFolder.Text := TPathBuilder.Build.EmbarcaderoUserAppDataRoamingPath();
  edtProgramDataFolder.Text := TPathBuilder.Build.EmbarcaderoProgramDataPath();
  edtPublicDocumentsFolder.Text := TPathBuilder.Build.EmbarcaderoPublicDocumentsPath();
  edtUserDocumentsFolder.Text := TPathBuilder.Build.EmbarcaderoUserDocumentsPath();
  edtEclipseAdoptiumFolder.Text := TPathBuilder.Build.EclipseAdoptiumPath();
  lblAddr.Text := Format('<%s>', [
    TCommonInfo.GetIpAddresses()
      .Remove(
        TCommonInfo.GetIpAddresses().LastIndexOf(sLineBreak),
        Length(sLineBreak))]);
  {$ENDIF SERVER}

  {$IFDEF CLIENT}
  if edtWineUserName.Text.IsEmpty then
    edtWineUserName.Text := TCommonInfo.GetCurrentUserName();
  edtEmbarcaderoDestFolder.Text :=
    TPathBuilder.Build.EmbarcaderoPath();
  edtEmbarcaderoAppDataRoamingDestFolder.Text :=
    TPathBuilder.Build.EmbarcaderoUserAppDataRoamingPath();
  edtEmbarcaderoProgramDataDestFolder.Text :=
    TPathBuilder.Build.EmbarcaderoProgramDataPath();
  edtEmbarcaderoUserDocumentsDestFolder.Text :=
    TPathBuilder.Build.EmbarcaderoUserDocumentsPath();
  edtEmbarcaderoPublicDocumentsDestFolder.Text :=
    TPathBuilder.Build.EmbarcaderoPublicDocumentsPath();
  edtEclipseAdoptiumDestFolder.Text :=
    TPathBuilder.Build.EclipseAdoptiumPath();
  edtTestProjectsDestFolder.Text :=
    TPathBuilder.Build.SampleProjectsPath();
  {$IFDEF DEBUG}
  edtHostAddr.Text := TCommonInfo.GetIpAddress();
  {$ENDIF DEBUG}
  {$ENDIF CLIENT}
end;

procedure TDelphi4Docker.CheckPaths;
begin
  {$IFDEF SERVER}
  TCommonPath.Check(edtEmbtFolder.Text);
  TCommonPath.Check(edtAppDataRoamingFolder.Text);
  TCommonPath.Check(edtProgramDataFolder.Text);
  TCommonPath.Check(edtEclipseAdoptiumFolder.Text);
  TCommonPath.Check(edtPublicDocumentsFolder.Text);
  TCommonPath.Check(edtUserDocumentsFolder.Text);
  {$ENDIF SERVER}

  {$IFDEF CLIENT}
  TWineHostEnvironmentPath.CheckWineFolder();
  TWineHostEnvironmentPath.CheckWineDriveCFolder();
  {$ENDIF CLIENT}
end;

function TDelphi4Docker.Connect: boolean;
begin
  {$IFDEF SERVER}
  FClient := FServer.Accept(10000) as TSocketDataFrame;
  Result := Assigned(FClient);
  {$ENDIF SERVER}

  {$IFDEF CLIENT}
  Result := FClient.Connect(edtHostAddr.Text, SERVER_PORT);
  {$ENDIF CLIENT}
end;

procedure TDelphi4Docker.CreateDefs;
begin
  fdmtDefs.CreateDataSet();
  TryLoadDefs();
  {$IFDEF SERVER}
  fdmtDefs.Edit();
  fdmtDefsuser_name.AsString := TCommonInfo.GetCurrentUserName();
  fdmtDefs.Post();
  {$ENDIF SERVER}
end;

procedure TDelphi4Docker.Disconnect;
begin
  if Assigned(FClient) then
    FClient.Close();

  {$IFDEF SERVER}
  FreeAndNil(FClient);
  {$ENDIF SERVER}
end;

procedure TDelphi4Docker.DoCancel;
begin
  Include(FStatus, TStatus.Cancelled);
  UpdateComponents();
  {$IFDEF SERVER}
  if (TStatus.Sending in FStatus) then
    FClient.Cancelled := true;
  {$ENDIF SERVER}

  {$IFDEF CLIENT}
  if (TStatus.Receiving in FStatus) then
    FClient.Cancelled := true;
  {$ENDIF CLIENT}
end;

procedure TDelphi4Docker.DoOperation(const AStatus: TStatus;
  const AProc: TProc);
begin
  if (AStatus = TStatus.Packing) and (TStatus.Sending in FStatus) then
    raise Exception.Create('Can''t run this operation while sending.');

  if (AStatus = TStatus.Sending) and (TStatus.Packing in FStatus) then
    raise Exception.Create('Can''t run this operation while packing.');

  if (AStatus = TStatus.Unpacking) and (TStatus.Receiving in FStatus) then
    raise Exception.Create('Can''t run this operation while receiving.');

  if (AStatus = TStatus.Receiving) and (TStatus.Unpacking in FStatus) then
    raise Exception.Create('Can''t run this operation while unpacking.');

  //If this is a new attempt, let's clear last error and cancelled status
  Exclude(FStatus, TStatus.Error);
  Exclude(FStatus, TStatus.Cancelled);
  //Execute the operation
  Include(FStatus, AStatus);
  try
    UpdateComponents();
    AProc();
    UpdateComponents();
    if (TStatus.Cancelled in FStatus) then
      TThread.Synchronize(TThread.Current, procedure() begin
        ShowMessage('Operation cancelled by user.');
      end);
    Exclude(FStatus, AStatus);
    UpdateComponents();
  except
    on E: Exception do begin
      Include(FStatus, TStatus.Error);
      UpdateComponents();
      Application.ShowException(E);
      Exclude(FStatus, AStatus);
      UpdateComponents();
    end;
  end;
end;

procedure TDelphi4Docker.edtWinePrefixChange(Sender: TObject);
begin
  FillForm();
end;

procedure TDelphi4Docker.edtWineUserNameChange(Sender: TObject);
begin
  FillForm();
end;

procedure TDelphi4Docker.TryLoadDefs;
begin
  if TFile.Exists(TCommonPath.GetDefsFile()) then
    fdmtDefs.LoadFromFile(TCommonPath.GetDefsFile(), TFDStorageFormat.sfJSON);
end;

procedure TDelphi4Docker.SearchEditButton13Click(Sender: TObject);
begin
  var LDirectory := String.Empty;
  if SelectDirectory('Select Sample Projects folder',
    TPathBuilder.Build.SampleProjectsPath(), LDirectory) then
      (TStyledControl(TStyledControl(Sender).Parent).Parent as TEdit).Text := LDirectory;
end;

procedure TDelphi4Docker.SearchEditButton1Click(Sender: TObject);
begin
  var LDirectory := String.Empty;
  if SelectDirectory('Select Embarcadero''s folder',
    TPathBuilder.Build.EmbarcaderoPath(), LDirectory) then
      (TStyledControl(TStyledControl(Sender).Parent).Parent as TEdit).Text := LDirectory;
end;

procedure TDelphi4Docker.SearchEditButton2Click(Sender: TObject);
begin
  var LDirectory := String.Empty;
  if SelectDirectory('Select AppData\Roaming folder',
    TPathBuilder.Build.EmbarcaderoUserAppDataRoamingPath(), LDirectory) then
      (TStyledControl(TStyledControl(Sender).Parent).Parent as TEdit).Text := LDirectory;
end;

procedure TDelphi4Docker.SearchEditButton3Click(Sender: TObject);
begin
  var LDirectory := String.Empty;
  if SelectDirectory('Select ProgramData folder',
    TPathBuilder.Build.EmbarcaderoProgramDataPath(), LDirectory) then
      (TStyledControl(TStyledControl(Sender).Parent).Parent as TEdit).Text := LDirectory;
end;

procedure TDelphi4Docker.SearchEditButton4Click(Sender: TObject);
begin
  var LDirectory := String.Empty;
  if SelectDirectory('Select Eclipse Adoptium folder',
    TPathBuilder.Build.EclipseAdoptiumPath, LDirectory) then
      (TStyledControl(TStyledControl(Sender).Parent).Parent as TEdit).Text := LDirectory;
end;

procedure TDelphi4Docker.SearchEditButton5Click(Sender: TObject);
begin
  var LDirectory := String.Empty;
  if SelectDirectory('Select Public Documents folder',
    TPathBuilder.Build.EmbarcaderoPublicDocumentsPath(), LDirectory) then
      (TStyledControl(TStyledControl(Sender).Parent).Parent as TEdit).Text := LDirectory;
end;

procedure TDelphi4Docker.SearchEditButton6Click(Sender: TObject);
begin
  var LDirectory := String.Empty;
  if SelectDirectory('Select User Documents folder',
    TPathBuilder.Build.EmbarcaderoUserDocumentsPath(), LDirectory) then
      (TStyledControl(TStyledControl(Sender).Parent).Parent as TEdit).Text := LDirectory;
end;

procedure TDelphi4Docker.btnReceiveClick(Sender: TObject);
begin
  FTask := TTask.Run(procedure() begin
    DoOperation(
      TStatus.Receiving,
      procedure() begin
        if TFile.Exists(TCommonPath.GetBundleFile()) then
          TFile.Delete(TCommonPath.GetBundleFile());

        if Connect() then
          try
            FClient.ReceiveData(
              TCommonPath.GetBundleFile(),
              TVisualUpdate.GetProgressBar(Sender as TPresentedControl));
          finally
            Disconnect();
          end;
      end);
  end);
end;

procedure TDelphi4Docker.btnSendClick(Sender: TObject);
begin
  FTask := TTask.Run(procedure() begin
    DoOperation(
      TStatus.Sending,
      procedure() begin
        if Connect() then
          FClient.SendData(
            TCommonPath.GetBundleFile(),
            TVisualUpdate.GetProgressBar(Sender as TPresentedControl));
      end);
  end);
end;

procedure TDelphi4Docker.AddToPack(const AFileName: string);
begin
  TMonitor.Enter(FPack);
  try
    if not TFile.Exists(TCommonPath.GetBundleFile()) then
      TFile.WriteAllText(TCommonPath.GetBundleFile(), String.Empty);

    FPack.Open(TCommonPath.GetBundleFile(), TZipMode.zmReadWrite);

    if AFileName.EndsWith('.zip') then
      FPack.Add(AFileName, TPath.GetFileName(AFileName), TZipCompression.zcStored)
    else
      FPack.Add(AFileName);

    FPack.Close();

    TMonitor.Pulse(FPack);
  finally
    TMonitor.Exit(FPack);
  end;
end;

procedure TDelphi4Docker.btnCancelClick(Sender: TObject);
begin
  DoCancel();
end;

procedure TDelphi4Docker.btnPackClick(Sender: TObject);
begin
  PackDirectly();
end;

procedure TDelphi4Docker.btnUnpackAndSetupClick(Sender: TObject);
begin
  UnpackDirectly();
end;

procedure TDelphi4Docker.UpdateComponents;
begin
  TThread.Synchronize(TThread.Current, procedure() begin
    {$IFDEF SERVER}
    btnPack.Enabled := true;
    btnCancel.Enabled := false;
    btnSend.Enabled := TFile.Exists(TCommonPath.GetBundleFile());

    if (TStatus.Packing in FStatus) then begin
      btnPack.Enabled := false;
      btnCancel.Enabled := true;
      btnSend.Enabled := false;
    end else if (TStatus.Sending in FStatus) then begin
      btnPack.Enabled := false;
      btnCancel.Enabled := true;
      btnSend.Enabled := false;
    end;

    if (TStatus.Cancelled in FStatus) then begin
      btnCancel.Enabled := false;
      if (TStatus.Packing in FStatus) then begin
        btnPack.Enabled := false;
        btnSend.Enabled := false;
      end;
    end;

    if (TStatus.Error in FStatus) then begin
      btnCancel.Enabled := false;
      if (TStatus.Packing in FStatus) then begin
        btnPack.Enabled := false;
        btnSend.Enabled := false;
      end;
    end;
    {$ENDIF SERVER}

    {$IFDEF CLIENT}
    btnUnpackAndSetup.Enabled := TFile.Exists(TCommonPath.GetBundleFile());
    btnReceive.Enabled := true;
    if (TStatus.Unpacking in FStatus) then begin
      btnUnpackAndSetup.Enabled := false;
      btnReceive.Enabled := false;
    end else if (TStatus.Receiving in FStatus) then begin
      btnUnpackAndSetup.Enabled := false;
      btnReceive.Enabled := false;
    end;

    if (TStatus.Cancelled in FStatus) then begin
      btnCancel.Enabled := false;
    end;

    if (TStatus.Error in FStatus) then begin
      btnCancel.Enabled := false;
    end;
    {$ENDIF CLIENT}
  end);
end;

function TDelphi4Docker.UpdateEdit(const AEdit: TEdit;
  const AProc: TProc): ITask;
begin
  Result := TTask.Run(procedure() begin
    AEdit.Enabled := false;
    try
      TVisualUpdate.UpdateSearch(AEdit, false);
      try
        TVisualUpdate.UpdateAni(AEdit, true);
        try
          AProc();
        finally
          TVisualUpdate.UpdateAni(AEdit, false);
        end;
      finally
        TVisualUpdate.UpdateSearch(AEdit, true);
      end;
    finally
      AEdit.Enabled := true;
    end;
  end);
end;

procedure TDelphi4Docker.ZipDirectoryContents(const ZipFileName, Path: string;
  const AProgressBar: TProgressBar);
var
  LZipFile: TZipFile;
  LFile: string;
  LZFile: string;
  LPath: string;
  LFiles: TStringDynArray;
begin
  LZipFile := TZipFile.Create;
  try
    if TFile.Exists(ZipFileName) then
      TFile.Delete(ZipFileName);
    LFiles := TDirectory.GetFiles(Path, '*', TSearchOption.soAllDirectories);
    LZipFile.Open(ZipFileName, zmWrite);
    LPath := System.SysUtils.IncludeTrailingPathDelimiter(Path);

    if Assigned(AProgressBar) then begin
      TThread.Queue(TThread.Current, procedure() begin
        AProgressBar.Max := Length(LFiles);
        AProgressBar.Value := 1;
        AProgressBar.Visible := true;
      end);
    end;

    try
      for LFile in LFiles do
      begin
        if (TStatus.Cancelled in FStatus) then
          Break;
        // Strip off root path
        {$IFDEF MSWINDOWS}
        LZFile := StringReplace(Copy(LFile, Length(LPath) + 1, Length(LFile)), '\', '/', [rfReplaceAll]);
        {$ELSE}
        LZFile := Copy(LFile, Length(LPath) + 1, Length(LFile));
        {$ENDIF MSWINDOWS}
        try
          LZipFile.Add(LFile, LZFile);
        except
          on E: EFOpenError do
          begin
            if TPath.IsUNCPath(LFile) then
              LZipFile.Add('\\?\UNC\' + LFile, LZFile)
            else
              LZipFile.Add('\\?\' + LFile, LZFile);
          end;
          else raise;
        end;

        if Assigned(AProgressBar) then
          TThread.Queue(TThread.Current, procedure() begin
            AProgressBar.Value := AProgressBar.Value + 1;
          end);
      end;
    finally
      if Assigned(AProgressBar) then begin
        TThread.Queue(TThread.Current, procedure() begin
          AProgressBar.Visible := false;
        end);
      end;
    end;
  finally
    LZipFile.Free;
  end;
end;

function TDelphi4Docker.ZipEdit(const AArchiveFileName: string;
  const AEdit: TEdit): ITask;
begin
  Result := UpdateEdit(AEdit, procedure() begin
    var LFileName := TPath.Combine(TCommonPath.GetBundleFolder(), AArchiveFileName);
    try
      ZipDirectoryContents(
        LFileName,
        AEdit.Text,
        TVisualUpdate.GetProgressBar(AEdit));

      if (TStatus.Cancelled in FStatus) then
        Exit;

      AddToPack(LFileName);
    except
      on E: Exception do
        Application.ShowException(E);
    end;
  end);
end;

procedure TDelphi4Docker.PackDirectly;
begin
  FTask := TTask.Run(procedure() begin
    DoOperation(
      TStatus.Packing,
      procedure() begin
        //Check for invalid paths
        CheckPaths();
        //Delete packing folder
        if TDirectory.Exists(TCommonPath.GetBundleFolder()) then
          TDirectory.Delete(TCommonPath.GetBundleFolder(), true);
        TDirectory.CreateDirectory(TCommonPath.GetBundleFolder());

        //Delete packing file
        if TFile.Exists(TCommonPath.GetBundleFile()) then
          TFile.Delete(TCommonPath.GetBundleFile());

        var LTasks: TArray<ITask> := [];
        var LTask: ITask := nil;
        {$IFDEF MSWINDOWS}
        //Export the Delphi registry
        LTask := TTask.Run(procedure() begin
          var LFileName := TCommonPath.GetRegistryFile();
          TWinOperation.ExportEmbarcaderoRegistry(LFileName);

          AddToPack(LFileName);
        end);
        LTasks := LTasks + [LTask];
        {$ENDIF MSWINDOWS}

        //Create the defs file
        LTask := TTask.Run(procedure() begin
          var LFileName := TCommonPath.GetDefsFile();
          fdmtDefs.SaveToFile(LFileName, TFDStorageFormat.sfJSON);

          AddToPack(LFileName);
        end);
        LTasks := LTasks + [LTask.Start];

        //Zip the Embarcadero folder
        LTask := ZipEdit('Embarcadero.zip', edtEmbtFolder);
        LTasks := LTasks + [LTask.Start];

        //Zip Embt's AppData folder
        LTask := ZipEdit('AppData.zip', edtAppDataRoamingFolder);
        LTasks := LTasks + [LTask.Start];

        //Zip Embt's ProgramData folder
        LTask := ZipEdit('ProgramData.zip', edtProgramDataFolder);
        LTasks := LTasks + [LTask.Start];

        //Zip Embt's Public Documents folder
        LTask := ZipEdit('PublicDocuments.zip', edtPublicDocumentsFolder);
        LTasks := LTasks + [LTask.Start];

        //Zip Embt's User Documents folder
        LTask := ZipEdit('UserDocuments.zip', edtUserDocumentsFolder);
        LTasks := LTasks + [LTask.Start];

        //Zip Eclipse Adoptium folder
        LTask := ZipEdit('EclipseAdoptium.zip', edtEclipseAdoptiumFolder);
        LTasks := LTasks + [LTask.Start];

        //Zip samples
        if not edtTestProjectsFolder.Text.Trim().IsEmpty() then
        LTask := ZipEdit('Samples.zip', edtTestProjectsFolder);
        LTasks := LTasks + [LTask.Start];

        //Get raised exceptions from any task an raise an EAggregateException
        TTask.WaitForAll(LTasks);

        if (TStatus.Cancelled in FStatus) then
          Exit;

        TThread.Synchronize(TThread.Current, procedure() begin
          ShowMessage('Package is ready to distribute.');
        end);

        {$IFDEF MSWINDOWS}
        TWinOperation.OpenExplorer(
          TPath.GetDirectoryName(TCommonPath.GetBundleFile()));
        {$ENDIF MSWINDOWS}
      end);
  end);
end;

procedure TDelphi4Docker.UnpackDirectly;
begin
  FTask := TTask.Run(procedure() begin
    DoOperation(
      TStatus.Unpacking,
      procedure() begin
        //Check for invalid paths
        CheckPaths();

        var LTasks: TArray<ITask> := [];
        var LTask := TTask.Run(procedure() begin
          var LZip := TZipFile.Create();
          try
            LZip.Open(TCommonPath.GetBundleFile(), TZipMode.zmRead);
            LZip.Extract(EMBT_REGISTRY_FILE_NAME, TCommonPath.GetBundleFolder());
            LZip.Extract(DEFS_FILE_NAME, TCommonPath.GetBundleFolder());
          finally
            LZip.Free();
          end;
        end);
        LTasks := LTasks + [LTask];

        LTask := UnzipEdit(TCommonPath.GetBundleFile(), 'Embarcadero.zip', edtEmbarcaderoDestFolder);
        LTasks := LTasks + [LTask];

        LTask := UnzipEdit(TCommonPath.GetBundleFile(), 'UserDocuments.zip', edtEmbarcaderoUserDocumentsDestFolder);
        LTasks := LTasks + [LTask];

        LTask := UnzipEdit(TCommonPath.GetBundleFile(), 'PublicDocuments.zip', edtEmbarcaderoPublicDocumentsDestFolder);
        LTasks := LTasks + [LTask];

        LTask := UnzipEdit(TCommonPath.GetBundleFile(), 'AppData.zip', edtEmbarcaderoAppDataRoamingDestFolder);
        LTasks := LTasks + [LTask];

        LTask := UnzipEdit(TCommonPath.GetBundleFile(), 'ProgramData.zip', edtEmbarcaderoProgramDataDestFolder);
        LTasks := LTasks + [LTask];

        LTask := UnzipEdit(TCommonPath.GetBundleFile(), 'EclipseAdoptium.zip', edtEclipseAdoptiumDestFolder);
        LTasks := LTasks + [LTask];

        var LZip := TZipFile.Create();
        try
          LZip.Open(TCommonPath.GetBundleFile(), TZipMode.zmRead);
          if LZip.IndexOf('Samples.zip') > -1 then begin
            LTask := UnzipEdit(TCommonPath.GetBundleFile(), 'Samples.zip', edtTestProjectsDestFolder);
            LTasks := LTasks + [LTask];
          end;
          LZip.Close();
        finally
          LZip.Free();
        end;

        TTask.WaitForAll(LTasks);

        if (TStatus.Cancelled in FStatus) then
          Exit;

        TThread.Synchronize(TThread.Current, procedure() begin
          ShowMessage('Environment has been set up.');
        end);
      end);
  end);
end;

function TDelphi4Docker.UnzipEdit(const AZipFileName, AArchiveFileName: string;
  const AEdit: TEdit): ITask;
begin
  Result := UpdateEdit(AEdit, procedure() begin
    var LFileName := TPath.Combine(TCommonPath.GetBundleFolder(), AArchiveFileName);
    try
      UnzipFileContents(
        AZipFileName,
        LFileName,
        AEdit.Text,
        TVisualUpdate.GetProgressBar(AEdit));

      if (TStatus.Cancelled in FStatus) then
        Exit;

      AddToPack(LFileName);
    except
      on E: Exception do
        Application.ShowException(E);
    end;
  end);
end;

procedure TDelphi4Docker.UnzipFileContents(const ZipFileName, AArchiveFileName,
  ADestPath: string; const AProgressBar: TProgressBar);
begin
  var LZipFile := TZipFile.Create();
  try
    LZipFile.Open(ZipFileName, TZipMode.zmRead);

    var LStream: TStream;
    var LHeader: TZipHeader;
    LZipFile.Read(AArchiveFileName, LStream, LHeader);
    try
      var LSubZip := TZipFile.Create();
      try
        LSubZip.Open(LStream, TZipMode.zmRead);

        if Assigned(AProgressBar) then begin
          var LFileCount := LSubZip.FileCount;
          TThread.Queue(TThread.Current, procedure() begin
            AProgressBar.Max := LFileCount;
            AProgressBar.Value := 1;
            AProgressBar.Visible := true;
          end);
        end;
        try
          for var I := 0 to LSubZip.FileCount - 1 do begin
            LSubZip.Extract(I, ADestPath);

            if Assigned(AProgressBar) then
              TThread.Queue(TThread.Current, procedure() begin
                AProgressBar.Value := AProgressBar.Value + 1;
              end);

            if (TStatus.Cancelled in FStatus) then
              Break;
          end;
        finally
          if Assigned(AProgressBar) then begin
            TThread.Queue(TThread.Current, procedure() begin
              AProgressBar.Visible := false;
            end);
          end;
        end;
      finally
        LSubZip.Free();
      end;
    finally
      LStream.Free();
    end;
  finally
    LZipFile.Free();
  end;
end;

{ TVisualUpdate }

class function TVisualUpdate.GetComp(const AClass: TClass;
  const AControl: TControl): TComponent;
begin
  Result := nil;

  if AControl is AClass then
    Exit(AControl);

  for var I := 0 to AControl.ControlsCount - 1 do
  begin
    Result := GetComp(AClass, AControl.Controls[I]);
    if Assigned(Result) then
      Break;
  end;
end;

class procedure TVisualUpdate.UpdateAni(const AEdit: TEdit;
  const AStatus: boolean);
begin
  var LAni := GetComp(TAniIndicator, AEdit) as TAniIndicator;
  if not Assigned(LAni) then
    Exit;

  TThread.Queue(TThread.Current, procedure() begin
    if AStatus then begin
      LAni.Enabled := true;
      LAni.Visible := true;
    end else begin
      LAni.Visible := false;
      LAni.Enabled := false;
    end;
  end);
end;

class procedure TVisualUpdate.UpdateSearch(const AEdit: TEdit;
  const AStatus: boolean);
begin
  var LSearch := GetComp(TSearchEditButton, AEdit) as TSearchEditButton;
  if not Assigned(LSearch) then
    Exit;

  TThread.Queue(TThread.Current, procedure() begin
    LSearch.Visible := AStatus;
  end);
end;

class function TVisualUpdate.GetProgressBar(const AControl: TPresentedControl): TProgressBar;
begin
  Result := GetComp(TProgressBar, AControl) as TProgressBar;
end;

end.
