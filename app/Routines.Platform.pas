unit Routines.Platform;

interface

type
  TStreamHandle = pointer;

  {$IFDEF MSWINDOWS}
  TWinOperation = class
  public
    class procedure ExportEmbarcaderoRegistry(const AFileName: string); static;
    class procedure OpenExplorer(const ADirectory: string); static;
  end;
  {$ENDIF MSWINDOWS}

  {$IFDEF LINUX}
  TLinuxOperation = class
  public
    class function ExecuteEmbarcaderoRegistry(const AFileName: string): string; static;
  end;
  {$ENDIF LINUX}

implementation

uses
  System.Classes, System.SysUtils
  {$IFDEF MSWINDOWS}
  , ShellApi, Winapi.Windows
  {$ENDIF MSWINDOWS}
  {$IFDEF LINUX}
  , Posix.Base, Posix.Fcntl
  {$ENDIF LINUX}
  ;

  {$IFDEF LINUX}
  function popen(const command: MarshaledAString; const _type: MarshaledAString): TStreamHandle; cdecl; external libc name _PU + 'popen';
  function pclose(filehandle: TStreamHandle): int32; cdecl; external libc name _PU + 'pclose';
  function fgets(buffer: pointer; size: int32; Stream: TStreamHandle): pointer; cdecl; external libc name _PU + 'fgets';
  {$ENDIF LINUX}

{ TWinOperation }

{$IFDEF MSWINDOWS}
class procedure TWinOperation.ExportEmbarcaderoRegistry(
  const AFileName: string);
var
 LSEInfo: TShellExecuteInfo;
 LExitCode: DWORD;
begin
  FillChar(LSEInfo, SizeOf(LSEInfo), 0);
  LSEInfo.cbSize := SizeOf(TShellExecuteInfo);
  with LSEInfo do begin
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := 0;
    lpFile := PChar('regedit.exe') ;
    lpParameters := PChar(
      Format(
        '/e "%s" "HKEY_CURRENT_USER\Software\Embarcadero"', [
        AFileName]));
    nShow := SW_HIDE;
  end;

  if ShellExecuteEx(@LSEInfo) then
    repeat
      GetExitCodeProcess(LSEInfo.hProcess, LExitCode);
    until (LExitCode <> STILL_ACTIVE);
end;

class procedure TWinOperation.OpenExplorer(const ADirectory: string);
begin
  ShellExecute(0, 'open', 'explorer.exe',
    PChar('/select,"' + ADirectory + '"'), nil, SW_NORMAL);
end;
{$ENDIF MSWINDOWS}

{ TLinuxOperation }

{$IFDEF LINUX}
class function TLinuxOperation.ExecuteEmbarcaderoRegistry(
  const AFileName: string): string;
var
  LHandle: TStreamHandle;
  LData: array[0..511] of uint8;
  LMarshaller : TMarshaller;
begin
  Result := String.Empty;
  LHandle := popen(LMarshaller.AsAnsi(PWideChar('wine regedit ' + AFileName)).ToPointer,'r');
  try
    while Assigned(fgets(@LData[0],Sizeof(LData), LHandle)) do begin
      Result := Result + Copy(UTF8ToString(@LData[0]), 1, UTF8ToString(@LData[0]).Length -1);
    end;
  finally
    pclose(LHandle);
  end;
end;
{$ENDIF LINUX}

end.
