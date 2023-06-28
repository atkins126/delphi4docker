unit Simple.Socket;

interface

uses
  System.Classes, System.SysUtils,
  FMX.StdCtrls,
  {$IFDEF MSWINDOWS}
  Winapi.WinSock2
  {$ENDIF}
  {$IFDEF POSIX}
    Posix.NetinetIn, Posix.ArpaInet, Posix.SysSocket, Posix.SysSelect
  {$ENDIF}
  , System.Net.Socket;

type
  TSimpleSocket = class(TSocket)
  private
    const DEFAULT_DATA_CHUNK_SIZE = $100000;
  private type
    TMessagePrologue = packed record
    public
      ContentLength: Int64;
    end;
    PMessageEpilogue = ^TMessageEpilogue;
    TMessageEpilogue = packed record
    public
      const EOM_MARKER: byte = $FF;
    public
      EOM: Byte;
    end;
  private
    FCancelled: boolean;
  protected
    function GetClientSocket(Handle: TSocketHandle; const Addr: sockaddr_in): TSocket; override;
  public
    constructor Create(); reintroduce; overload;
    //Server actions
    procedure Listen(const AIp: string; const APort: integer); reintroduce;
    //Client actions
    function Connect(const AIp: string; const APort: integer): boolean; reintroduce;
    //Data exchange
    procedure InitSendData(const AMessageSize: Int64;
      const ATransmitter: TProc<TProc<TBytes>>; const AProgress: TProgressBar);
    procedure SendData(const AFileName: string; const AProgress: TProgressBar);
    function InitReceiveData(
      const AReceiver: TProc<TFunc<TBytes>>; const AProgress: TProgressBar): TMessagePrologue;
    procedure ReceiveData(const AFileName: string; const AProgress: TProgressBar);
  public
    property Cancelled: boolean read FCancelled write FCancelled;
  end;

implementation

constructor TSimpleSocket.Create;
begin
  inherited Create(TSocketType.TCP, TEncoding.UTF8);
end;

function TSimpleSocket.GetClientSocket(Handle: TSocketHandle;
  const Addr: sockaddr_in): TSocket;
begin
  Result := TSimpleSocket.Create(Handle, Addr, Encoding);
end;

procedure TSimpleSocket.Listen(const AIp: string; const APort: integer);
begin
  inherited Listen(TNetEndpoint.Create(TIPAddress.Create(AIp), APort), 1);
end;

function TSimpleSocket.Connect(const AIp: string; const APort: integer): boolean;
begin
  inherited Connect(TNetEndpoint.Create(TIPAddress.Create(AIp), APort));
  Result := (TSocketState.Connected in Self.State);
end;

function TSimpleSocket.InitReceiveData(
  const AReceiver: TProc<TFunc<TBytes>>; const AProgress: TProgressBar): TMessagePrologue;
begin
  var LResult := Default(TMessagePrologue);
  try
    //Receive prologue
    if not (Self.Receive(LResult, SizeOf(TMessagePrologue)) = SizeOf(TMessagePrologue)) then
      raise Exception.Create('Invalid message header');

    if not Assigned(AReceiver) then
      Exit;

    if Assigned(AProgress) then
      TThread.Queue(TThread.Current, procedure() begin
        AProgress.Max := 100;
        AProgress.Value := 0;
        AProgress.Visible := true;
      end);

    var LTotalReceived: Int64 := 0;
    try
      AReceiver(
        function(): TBytes begin
          var LChunckSize: integer := DEFAULT_DATA_CHUNK_SIZE;
          if (LTotalReceived = LResult.ContentLength) then
            LChunckSize := SizeOf(TMessageEpilogue) //To receive epilogue
          else if ((LResult.ContentLength - LTotalReceived) < LChunckSize) then
            LChunckSize := (LResult.ContentLength - LTotalReceived);

          var LCount := Self.Receive(Result, LChunckSize);
          SetLength(Result, LCount);

          if (LTotalReceived = LResult.ContentLength) and (LCount = SizeOf(TMessageEpilogue)) then begin
            try
              if (PMessageEpilogue(Pointer(Result))^.EOM = TMessageEpilogue.EOM_MARKER) then
                Exit(nil);
            except
              //
            end;
          end;

          if (LCount = 0) then
            Exit(nil);

          Inc(LTotalReceived, LCount);

          if Assigned(AProgress) then
            TThread.Queue(TThread.Current, procedure() begin
              AProgress.Value := (LTotalReceived * LResult.ContentLength) div 100;
            end);
        end);
    finally
      if Assigned(AProgress) then
        TThread.Queue(TThread.Current, procedure() begin
          AProgress.Visible := false;
        end);
    end;
  except
    //
  end;

  Result := LResult;
end;

procedure TSimpleSocket.InitSendData(const AMessageSize: Int64;
  const ATransmitter: TProc<TProc<TBytes>>; const AProgress: TProgressBar);
begin
  var LPrologue := Default(TMessagePrologue);
  LPrologue.ContentLength := AMessageSize;

  //Send prologue
  if not (Self.Send(LPrologue, SizeOf(TMessagePrologue)) = SizeOf(TMessagePrologue)) then
    raise Exception.Create('Invalid message header');

  if not Assigned(ATransmitter) then
    Exit;

  if Assigned(AProgress) then
    TThread.Queue(TThread.Current, procedure() begin
      AProgress.Max := 100;
      AProgress.Value := 0;
      AProgress.Visible := true;
    end);

  var LTotalSent: Int64 := 0;
  try
    ATransmitter(
      //send body in chunks of data
      procedure(ABytes: TBytes) begin
        Self.Send(ABytes, 0, Length(ABytes));
        Inc(LTotalSent, Length(ABytes));
        if Assigned(AProgress) then
          TThread.Queue(TThread.Current, procedure() begin
            AProgress.Value := (LTotalSent * AMessageSize) div 100;
          end);
      end);

    //Send epilogue
    var LEpilogue := Default(TMessageEpilogue);
    LEpilogue.EOM := TMessageEpilogue.EOM_MARKER;
    Self.Send(LEpilogue, SizeOf(TMessageEpilogue));
  finally
    if Assigned(AProgress) then
      TThread.Queue(TThread.Current, procedure() begin
        AProgress.Visible := false;
      end);
  end;
end;

procedure TSimpleSocket.SendData(const AFileName: string; const AProgress: TProgressBar);
begin
  FCancelled := false;
  var LFileStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    InitSendData(
      LFileStream.Size,
      procedure(AStep: TProc<TBytes>) begin
        var LBinaryReader := TBinaryReader.Create(LFileStream);
        try
          while not FCancelled do begin
            var LChunk := LBinaryReader.ReadBytes(DEFAULT_DATA_CHUNK_SIZE);

            if not Assigned(LChunk) then
              Break;

            AStep(LChunk);
          end;
        finally
          LBinaryReader.Free;
        end;
      end,
      AProgress);
  finally
    LFileStream.Free();
  end;
end;

procedure TSimpleSocket.ReceiveData(const AFileName: string;
  const AProgress: TProgressBar);
begin
  FCancelled := false;
  var LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    InitReceiveData(procedure(ARead: TFunc<TBytes>) begin
      while not FCancelled do begin
        var LBytes := ARead();
        if not Assigned(LBytes) then
          Exit;
        LFileStream.Write(LBytes, Length(LBytes));
      end;
    end,
    AProgress);
  finally
    LFileStream.Free();
  end;
end;

end.
