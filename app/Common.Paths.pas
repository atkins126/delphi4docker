unit Common.Paths;

interface

uses
  System.SysUtils, System.IOUtils;

type
  TCommonPath = class
  public
    class function GetBundleFolder: string; static;
    class function GetBundleFile: string; static;
    class function GetRegistryFile: string; static;
    class function GetDefsFile(): string; static;
    class function GetLogFile(): string; static;
    //Validators
    class procedure Check(const APath: string); static;
  end;

  IEnvironmentPath = Interface
    ['{265932AF-0556-4018-BBC5-9C3A0F989850}']
    function EmbarcaderoPath(): string;
    function EmbarcaderoProgramDataPath(): string;
    function EmbarcaderoUserDocumentsPath(): string;
    function EmbarcaderoUserProjectsPath(): string;
    function EmbarcaderoPublicDocumentsPath(): string;
    function EmbarcaderoUserAppDataRoamingPath(): string;
    function EclipseAdoptiumPath(): string;
    function SampleProjectsPath(): string;
  end;

  TPathBuilder = class
  private type
    TEnvironmentPathBuilder = TFunc<IEnvironmentPath>;
  private
    class var FDelegator: TEnvironmentPathBuilder;
  public
    class function Build: IEnvironmentPath; static;
    class property Delegator: TEnvironmentPathBuilder read FDelegator write FDelegator;
  end;

  TLocalEnvironmentPath = class(TInterfacedObject, IEnvironmentPath)
  private
    FUserName: string;
  public
    constructor Create(const AUserName: string = '');

    function EmbarcaderoPath(): string;
    function EmbarcaderoProgramDataPath(): string;
    function EmbarcaderoUserDocumentsPath(): string;
    function EmbarcaderoUserProjectsPath(): string;
    function EmbarcaderoPublicDocumentsPath(): string;
    function EmbarcaderoUserAppDataRoamingPath(): string;
    function EclipseAdoptiumPath(): string;
    function SampleProjectsPath(): string;
  end;

  TWineHostEnvironmentPath = class(TInterfacedObject, IEnvironmentPath)
  private
    FWinePrefix: string;
    FWineUserName: string;
    FHostUserName: string;
  private
    function GetWineFolder(): string;
    function GetWineDriveCFolder(): string;
    function GetWineUsersDirectory(): string;
    function GetWineUserDirectory(): string;
    function GetWineUserDocumentsDirectory(): string;
  public
    constructor Create(const AWinePrefix, AWineUserName: string; AHostUserName: string = '');

    function EmbarcaderoPath(): string;
    function EmbarcaderoProgramDataPath(): string;
    function EmbarcaderoUserDocumentsPath(): string;
    function EmbarcaderoUserProjectsPath(): string;
    function EmbarcaderoPublicDocumentsPath(): string;
    function EmbarcaderoUserAppDataRoamingPath(): string;
    function EclipseAdoptiumPath(): string;
    function SampleProjectsPath(): string;

    class procedure CheckWineFolder(); static;
    class procedure CheckWineDriveCFolder(); static;
  end;

  TCommonInfo = class
  public
    class function GetCurrentUserName(): string; static;
    class function GetIpAddress: string; static;
    class function GetIpAddresses: string; static;
  end;

const
  EMBT_REGISTRY_FILE_NAME = 'Embarcadero.reg';
  DEFS_FILE_NAME = 'defs.json';

implementation

uses
  IdStack;

const
  PACK_ZIP_FILE_NAME = 'delphipack.zip';
  PACK_FOLDER_NAME = 'delphipack';
  LOG_FILE_NAME = 'log.txt';

{ TCommonInfo }

class function TCommonInfo.GetCurrentUserName: string;
begin
  Result := GetEnvironmentVariable('USERNAME');
  {$IFDEF CLIENT}
  if Result.IsEmpty then
    Result := 'root';
  {$ENDIF CLIENT}
end;

class function TCommonInfo.GetIpAddress: string;
begin
  TIdStack.IncUsage();
  try
    Result := GStack.LocalAddress;
  finally
    TIdStack.DecUsage();
  end;
end;

class function TCommonInfo.GetIpAddresses: string;
begin
  TIdStack.IncUsage();
  try
    Result := GStack.LocalAddresses.Text;
  finally
    TIdStack.DecUsage();
  end;
end;

{ TCommonPath }

class function TCommonPath.GetBundleFolder: string;
begin
  Result := TPath.Combine(ExtractFilePath(TPath.GetFullPath(ParamStr(0))), PACK_FOLDER_NAME);
end;

class procedure TCommonPath.Check(const APath: string);
begin
  if not TDirectory.Exists(APath) and not TFile.Exists(APath) then
    raise Exception.CreateFmt('Invalid path: "%s"', [APath]);
end;

class function TCommonPath.GetBundleFile: string;
begin
  Result := TPath.Combine(ExtractFilePath(TPath.GetFullPath(ParamStr(0))), PACK_ZIP_FILE_NAME);
end;

class function TCommonPath.GetDefsFile: string;
begin
  Result := TPath.Combine(TCommonPath.GetBundleFolder(), DEFS_FILE_NAME);
end;

class function TCommonPath.GetLogFile: string;
begin
  Result := TPath.Combine(ExtractFilePath(TPath.GetFullPath(ParamStr(0))), LOG_FILE_NAME);
end;

class function TCommonPath.GetRegistryFile: string;
begin
  Result := TPath.Combine(GetBundleFolder(), EMBT_REGISTRY_FILE_NAME);
end;

{ TPathBuilder }

class function TPathBuilder.Build: IEnvironmentPath;
begin
  Assert(Assigned(FDelegator), 'Builder not assigned.');
  Result := FDelegator();
end;

{ TLocalEnvironmentPath }

constructor TLocalEnvironmentPath.Create(const AUserName: string);
begin
  inherited Create();
  FUserName := AUserName;
end;

function TLocalEnvironmentPath.EmbarcaderoPath: string;
begin
  Result := 'C:\Program Files (x86)\Embarcadero';
end;

function TLocalEnvironmentPath.EmbarcaderoProgramDataPath: string;
begin
  Result := 'C:\ProgramData\Embarcadero';
end;

function TLocalEnvironmentPath.EmbarcaderoPublicDocumentsPath: string;
begin
  Result := 'C:\Users\Public\Documents\Embarcadero';
end;

function TLocalEnvironmentPath.EmbarcaderoUserAppDataRoamingPath: string;
begin
  var LUserName := FUserName;
  if LUserName.IsEmpty then
    LUserName := TCommonInfo.GetCurrentUserName();

  Result := Format('C:\Users\%s\AppData\Roaming\Embarcadero', [LUserName])
end;

function TLocalEnvironmentPath.EmbarcaderoUserDocumentsPath: string;
begin
  var LUserName := FUserName;
  if LUserName.IsEmpty then
    LUserName := TCommonInfo.GetCurrentUserName();

  Result := Format('C:\Users\%s\Documents\Embarcadero', [LUserName]);
end;

function TLocalEnvironmentPath.EmbarcaderoUserProjectsPath: string;
begin
  Result :=
    TPath.Combine(
      TPath.Combine(
        EmbarcaderoUserDocumentsPath(),
        'Studio'),
      'Projects'
    );
end;

function TLocalEnvironmentPath.EclipseAdoptiumPath: string;
begin
  Result := 'C:\Program Files\Eclipse Adoptium';
end;

function TLocalEnvironmentPath.SampleProjectsPath: string;
begin
  Result := Format('%s\Studio\Projects', [EmbarcaderoUserDocumentsPath()]);
end;

{ TWineHostEnvironmentPath }

function TWineHostEnvironmentPath.GetWineFolder: string;
begin
  var LWineUserName := FWineUserName;
  if LWineUserName.IsEmpty then
    LWineUserName := TCommonInfo.GetCurrentUserName();

  if LWineUserName.IsEmpty then
    LWineUserName := 'root';

  ///root/$(wineprefix)
  if (LWineUserName = 'root') then
    Exit(TPath.Combine(TPath.DirectorySeparatorChar + 'root', FWinePrefix));

  ///home/$(user)/$(wineprefix)
  Result :=
    TPath.Combine(
      TPath.Combine(TPath.DirectorySeparatorChar + 'home', LWineUserName),
    FWinePrefix);
end;

function TWineHostEnvironmentPath.GetWineDriveCFolder: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c
  Result := TPath.Combine(GetWineFolder(), 'drive_c');
end;

function TWineHostEnvironmentPath.GetWineUsersDirectory: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/users
  Result := TPath.Combine(GetWineDriveCFolder(), 'users');
end;

function TWineHostEnvironmentPath.GetWineUserDirectory: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/users/$(wineuser)
  Result := TPath.Combine(GetWineUsersDirectory(), FWineUserName);
end;

function TWineHostEnvironmentPath.GetWineUserDocumentsDirectory: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/users/$(wineuser)/Documents
  Result := TPath.Combine(GetWineUserDirectory(), 'Documents');
end;

constructor TWineHostEnvironmentPath.Create(const AWinePrefix,
  AWineUserName: string; AHostUserName: string);
begin
  inherited Create();
  FWinePrefix := AWinePrefix;
  FWineUserName := AWineUserName;
  FHostUserName := AHostUserName;
end;

function TWineHostEnvironmentPath.EmbarcaderoPath: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/Program Files (x86)/Embarcadero
  Result :=
    TPath.Combine(
      TPath.Combine(
        GetWineDriveCFolder(),
        'Program Files (x86)'),
      'Embarcadero');
end;

function TWineHostEnvironmentPath.EmbarcaderoProgramDataPath: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/ProgramData/Embarcader
  Result :=
    TPath.Combine(
      TPath.Combine(
        GetWineDriveCFolder(),
        'ProgramData'),
      'Embarcadero');
end;

function TWineHostEnvironmentPath.EmbarcaderoPublicDocumentsPath: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/users/Public/Documents/Embarcadero
  Result :=
    TPath.Combine(
      TPath.Combine(
        TPath.Combine(
          GetWineUsersDirectory(),
          'Public'),
      'Documents'),
    'Embarcadero');
end;

function TWineHostEnvironmentPath.EmbarcaderoUserAppDataRoamingPath: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/users/$(wineuser)/AppData/Roaming
  Result :=
    TPath.Combine(
      TPath.Combine(
        TPath.Combine(
          GetWineUserDirectory(),
          'AppData'),
        'Roaming'),
      'Embarcadero'
    );
end;

function TWineHostEnvironmentPath.EmbarcaderoUserDocumentsPath: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/users/$(wineuser)/Documents/Embarcadero
  Result := TPath.Combine(GetWineUserDocumentsDirectory(), 'Embarcadero');
end;

function TWineHostEnvironmentPath.EmbarcaderoUserProjectsPath: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/users/$(wineuser)/Documents/Embarcadero/Studio/Projects
  Result :=
    TPath.Combine(
      TPath.Combine(
        EmbarcaderoUserDocumentsPath(),
        'Studio'),
      'Projects'
    );
end;

function TWineHostEnvironmentPath.EclipseAdoptiumPath: string;
begin
  ///home/$(user)/$(wineprefix)/drive_c/Program Files/Eclipse Adoptium
  Result :=
    TPath.Combine(
      TPath.Combine(
        GetWineDriveCFolder(),
        'Program Files'),
    'Eclipse Adoptium');
end;

function TWineHostEnvironmentPath.SampleProjectsPath: string;
begin
  Result :=
    TPath.Combine(
      TPath.Combine(
        EmbarcaderoUserDocumentsPath(),
        'Studio'),
      'Projects');
end;

class procedure TWineHostEnvironmentPath.CheckWineDriveCFolder;
begin
  with (TPathBuilder.Build as TWineHostEnvironmentPath) do
    TCommonPath.Check(GetWineDriveCFolder());
end;

class procedure TWineHostEnvironmentPath.CheckWineFolder;
begin
  with (TPathBuilder.Build as TWineHostEnvironmentPath) do
    TCommonPath.Check(GetWineFolder());
end;

end.
