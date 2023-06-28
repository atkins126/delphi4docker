unit Routines.Windows;

interface

  {$IFDEF MSWINDOWS}
type
  TWinOperation = class
  public
    class procedure ExportEmbarcaderoRegistry(const AFileName: string); static;
    class procedure OpenExplorer(const ADirectory: string); static;
  end;
  {$ENDIF MSWINDOWS}

implementation

uses
  System.SysUtils
  {$IFDEF MSWINDOWS}
  , ShellApi, Winapi.Windows
  {$ENDIF MSWINDOWS}
  ;

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

end.
