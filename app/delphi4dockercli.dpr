program delphi4dockercli;

uses
  System.StartUpCopy,
  FMX.Forms,
  Form.Delphi4Docker in 'Form.Delphi4Docker.pas' {Delphi4Docker},
  Common.Paths in 'Common.Paths.pas',
  Socket.Data.Frame in 'Socket.Data.Frame.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDelphi4Docker, Delphi4Docker);
  Application.Run;
end.
