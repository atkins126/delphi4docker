program delphi4dockersrv;

uses
  System.StartUpCopy,
  FMX.Forms,
  Form.Delphi4Docker in 'Form.Delphi4Docker.pas' {Delphi4Docker},
  Socket.Data.Frame in 'Socket.Data.Frame.pas',
  Routines.Platform in 'Routines.Platform.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDelphi4Docker, Delphi4Docker);
  Application.Run;
end.
