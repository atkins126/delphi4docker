unit Socket.Data.Frame;

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
  TSocketDataFrame = class(TSocket)
  private
    const DEFAULT_DATA_CHUNK_SIZE = 65536;
  private type
    PMessagePrologue = ^TMessagePrologue;
    TMessagePrologue = packed record
    public
      const BOM_MARKER: byte = $01;
    public
      BOM: byte;
      ContentLength: Int64;
    end;

    PMessageEpilogue = ^TMessageEpilogue;
    TMessageEpilogue = packed record
    public
      const EOM_MARKER: byte = $FF;
    public
      EOM: Byte;
      //We can add a checksum here
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

uses
  System.Generics.Collections;

constructor TSocketDataFrame.Create;
begin
  inherited Create(TSocketType.TCP, TEncoding.UTF8);
end;

function TSocketDataFrame.GetClientSocket(Handle: TSocketHandle;
  const Addr: sockaddr_in): TSocket;
begin
  Result := TSocketDataFrame.Create(Handle, Addr, Encoding);
end;

procedure TSocketDataFrame.Listen(const AIp: string; const APort: integer);
begin
  inherited Listen(TNetEndpoint.Create(TIPAddress.Create(AIp), APort), 1);
end;

function TSocketDataFrame.Connect(const AIp: string; const APort: integer): boolean;
begin
  inherited Connect(TNetEndpoint.Create(TIPAddress.Create(AIp), APort));
  Result := (TSocketState.Connected in Self.State);
end;

function TSocketDataFrame.InitReceiveData(
  const AReceiver: TProc<TFunc<TBytes>>; const AProgress: TProgressBar): TMessagePrologue;
begin
  //Receive prologue
  var LMessagePrologue := Default(TMessagePrologue);
  //We are not bufferizing extra content. If we need it in the future, let's assign the extra content field to this LBuffer
  var LBuffer: TBytes := nil;
  while not FCancelled do begin
    var LData: TBytes;
    if (Receive(LData) > 0) then begin
      //Buffering data
      LBuffer := LBuffer + LData;
      if Length(LBuffer) >= SizeOf(TMessagePrologue) then begin
        //Fill up prologue data
        LMessagePrologue.BOM := PMessagePrologue(Pointer(LBuffer))^.BOM;
        LMessagePrologue.ContentLength := PMessagePrologue(Pointer(LBuffer))^.ContentLength;
        //Check for a valid prologue
        if not (LMessagePrologue.BOM = TMessagePrologue.BOM_MARKER) or (LMessagePrologue.ContentLength <= 0) then
          raise Exception.Create('Invalid message prologue');
        //Remove prologue from buffer
        Delete(LBuffer, 0, SizeOf(TMessagePrologue));
        //We received the message prologue. We can read content now.
        Break;
      end;
    end;
  end;

  if not Assigned(AReceiver) then
    Exit;

  if Assigned(AProgress) then
    TThread.Queue(TThread.Current, procedure() begin
      AProgress.Max := 100;
      AProgress.Value := 0;
      AProgress.Visible := true;
    end);

  var LTotalReceived: Int64 := Length(LBuffer);
  try
    var LExtraBuffer := TBytes(nil);
    AReceiver(
      function(): TBytes begin
        var LData: TBytes;
        try
          //Receive data until we reach out the message epilogue
          while not FCancelled do begin
            //Receive data from server
            var LCount := Self.Receive(LData);

            //Concat buffered data and then clear the buffer
            LData := LData + LBuffer;
            LBuffer := nil;
            Inc(LTotalReceived, LCount);

            //No data? Continue... but we can have a buffered epilogue
            if not Assigned(LData) and not Assigned(LExtraBuffer) then
              Continue;

            //Do we reached out message length?
            if (LTotalReceived > LMessagePrologue.ContentLength) then begin
              //Part of this data might be withing content length. We must extract it.
              var LExtraContentLength := (LTotalReceived - LMessagePrologue.ContentLength);
              //Bufferize extra content
              if not Assigned(LExtraBuffer) then begin
                //Copy message only
                var LRemainingDataLength := Length(LData) - LExtraContentLength;
                if (LRemainingDataLength > 0) then begin
                  SetLength(Result, LRemainingDataLength);
                  TArray.Copy<Byte>(LData, Result, 0, 0, Length(Result));
                end else
                  Result := nil;
                //Bufferize extra message until we reach out epilogue
                SetLength(LExtraBuffer, LExtraContentLength);
                TArray.Copy<Byte>(LData, LExtraBuffer, Length(LData) - LExtraContentLength, 0, LExtraContentLength);
                //Maybe there's only the epilogue remaining. Must check it before continue.
                if Assigned(Result) then
                  Exit(Result);
              end else
                LExtraBuffer := LExtraBuffer + LData;

              //Continue until we receive the whole epilogue
              if (Length(LExtraBuffer) < SizeOf(TMessageEpilogue)) then
                Continue;

              //We are not bufferizing extra content here... extra content might be part of a next message...
              //If we need it in the future, this is where we should place a field and store the extra content.

              //Check for end of message confirmation
              if (PMessageEpilogue(Pointer(LExtraBuffer))^.EOM = TMessageEpilogue.EOM_MARKER) then
                Exit(nil)
              else
                raise Exception.Create('Invalid message epilogue');
            end else
              Exit(LData);
          end;
        finally
          if Assigned(AProgress) then
            TThread.Queue(TThread.Current, procedure() begin
              AProgress.Value := (LTotalReceived / LMessagePrologue.ContentLength) * 100;
            end);
        end;
      end);
  finally
    if Assigned(AProgress) then
      TThread.Queue(TThread.Current, procedure() begin
        AProgress.Visible := false;
      end);
  end;

  Result := LMessagePrologue;
end;

procedure TSocketDataFrame.InitSendData(const AMessageSize: Int64;
  const ATransmitter: TProc<TProc<TBytes>>; const AProgress: TProgressBar);
begin
  var LPrologue := Default(TMessagePrologue);
  LPrologue.BOM := TMessagePrologue.BOM_MARKER;
  LPrologue.ContentLength := AMessageSize;

  //Send prologue
  if not (Self.Send(LPrologue, SizeOf(TMessagePrologue)) = SizeOf(TMessagePrologue)) then
    raise Exception.Create('Invalid message prologue');

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
        if Assigned(AProgress) then begin
          TThread.Queue(TThread.Current, procedure() begin
            AProgress.Value := (LTotalSent / AMessageSize) * 100;
          end);
        end;
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

procedure TSocketDataFrame.SendData(const AFileName: string; const AProgress: TProgressBar);
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

procedure TSocketDataFrame.ReceiveData(const AFileName: string;
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
