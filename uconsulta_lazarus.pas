unit uconsulta_lazarus;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Buttons, DB, sqlite3conn, sqldb,
  IBConnection, DBCtrls, Grids, DBGrids, MaskEdit, Menus, UITYpes;

const
  //ALERTAS
  ERRO_SRV    = 'Erro inicializando servidor.';
  START_SRV   = 'Servidor inicializado com sucesso.';
  STOP_SRV    = 'Servidor interrompido.';

  SQLITEDB    = 'DBProdutos.sdb';
  //versao 1..0.0.2
  //CRIATABLE   = 'CREATE TABLE "Produtos" ("BarCode"     Char(50),"Produto"     Char(20),"Preco"       Currency )';
  //CRIATABLE   = 'CREATE TABLE "Produtos" ("BarCode"     Char(50),"Produto"     Char(50),"Preco"       Currency )';
  CRIATABLE   = 'CREATE TABLE "Produtos" ("BarCode"     Char(50),"Produto"     Char(50),"Preco"       Currency, "Linha3" Cha(50), "Linha4" Char(50) )';
  {$IFDEF WIN64}
  VP_DLL      = 'VP_v3_x64.DLL';
  {$ELSE}
  VP_DLL      = 'VP_v3.DLL';
  {$ENDIF}

type TIPV4 = record
  d,c,b,a: byte;
end;

type stAddress = record
  Ip    : PAnsiChar;
  Socket: Word;
end;

type
  TTABSOCK = record
    TabSock: array[0..1023] of Word;
    TabIP: array[0..1023] of DWORD;
    NumSockConec: integer;
end;

type

  { TFConsulta }

  TFConsulta = class(TForm)
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    SQLConnector: TSQLConnector;
    SQLQuery: TSQLQuery;
    SQLTransaction: TSQLTransaction;
    TabMensagens: TTabSheet;
    Panel1: TPanel;
    TabMonitora: TTabSheet;
    BtnMonitora: TBitBtn;
    BtnMensagens: TBitBtn;
    PC: TPageControl;
    Image1: TImage;
    ListTerms: TListBox;
    Timer100ms: TTimer;
    Timer3Seg: TTimer;
    TxtConectados: TStaticText;
    StaticText2: TStaticText;
    MemoRecv: TMemo;
    BtnIniciar: TBitBtn;
    BtnLimparMemo: TButton;
    GrpIMsg: TGroupBox;
    LabLine1: TLabel;
    LabLine2: TLabel;
    LabTimeEx: TLabel;
    EdtLine1: TEdit;
    EdtLine2: TEdit;
    EdtTimeEx: TEdit;
    BtnMsgSend: TButton;
    Label1: TLabel;
    EditUnidMon: TLabeledEdit;
    procedure BtnMonitoraClick(Sender: TObject);
    procedure BtnMensagensClick(Sender: TObject);
    procedure BtnIniciarClick(Sender: TObject);
    procedure BtnLimparMemoClick(Sender: TObject);
    procedure BtnMsgSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListTermsClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure Timer100msTimer(Sender: TObject);
    procedure Timer3SegTimer(Sender: TObject);


  private
    { Private declarations }
    function CarregaDLL: Boolean;
    function GetEXEVersionData(const FileName: string): String;
  public
    { Public declarations }
    TabTerms: TTABSOCK;

  end;
var
  FConsulta: TFConsulta;
  SelTerm: integer;


var
//------------------------------------------------------------------------------
//dll_v3
{
  procedure vInitialize; stdcall; far;
  function  tc_startserver: integer; stdcall; far;
  function  GetTabConectados(nada: integer): TTABSOCK; stdcall; far;
  function  bConnected(out ID_WIp: DWORD; out ID_Socket: integer): boolean; far;
  function  bDisconnected(out ID_WIp: DWORD; out ID_Socket: integer): boolean; far;
  function  bCloseTerminal(ID_Ip: DWORD; ID_Socket: integer): boolean; far; stdcall;
  function  Inet_NtoA(nIP: DWORD): PAnsiChar; far; stdcall;
  function  Inet_Addr(sIP: PAnsiChar): DWORD; far; stdcall;
  function  bSendDisplayMsg(ID: DWORD; Linha1: PAnsiChar; Linha2: PAnsiChar;
  function  bReceiveBarcode(out ID_IP: DWORD; out ID_Socket: integer; out Nbr: integer): PAnsiChar; stdcall; far;
  function  bSendProdNotFound(ID: DWORD): boolean; far; stdcall;
  function  bSendProdPrice(ID: DWORD; NameProd: PAnsiChar; PriceProd: PAnsiChar):
  function  dll_version: PAnsiChar; stdcall; far;
  function  bTerminate: boolean; far; stdcall;
}
  GetTabConectados  : function  (nada: integer): TTABSOCK; stdcall = nil;
  Inet_NtoA         : function  (nIP: DWORD): PAnsiChar; stdcall = nil;
  vInitialize       : procedure ; stdcall = nil;
  tc_startserver    : function  : integer; stdcall = nil;
  bTerminate        : function  : boolean; stdcall = nil;
  bSendDisplayMsg   : function  (ID: DWORD; Linha1: PAnsiChar; Linha2: PAnsiChar; Tempo: Integer): Boolean; stdcall = nil;
  bSendProdNotFound : function  (ID: DWORD): boolean;stdcall = nil;
  bSendProdPrice    : function  (ID: DWORD; NameProd: PAnsiChar; PriceProd: PAnsiChar): Boolean; stdcall = nil;
  bReceiveBarcode   : function  (out ID_IP: DWORD; out ID_Socket: Word; out Nbr: integer): PAnsiChar; stdcall = nil;
  bConnected        : function  (out ID_WIp: DWORD; out ID_Socket: Word): boolean; stdcall = nil;
  bDisconnected     : function  (out ID_WIp: DWORD; out ID_Socket: Word): boolean; stdcall = nil;
  bCloseTerminal    : function  (ID_Ip: DWORD; ID_Socket: Word): boolean; stdcall = nil;
  Inet_Addr         : function  (sIP: PAnsiChar): DWORD; stdcall = nil;
  dll_version       : function  : PAnsiChar; stdcall = nil;

//------------------------------------------------------------------------------

implementation

{$R *.lfm}

procedure TFConsulta.BtnIniciarClick(Sender: TObject);
begin
  if (BtnIniciar.Caption = 'Parar') then
  begin
    if (bTerminate = true) then
    begin
      MemoRecv.Lines.Add(STOP_SRV);
      Timer3seg.Enabled := false;
      Timer100ms.Enabled := false;
      BtnIniciar.Caption := 'Iniciar';
      BtnMonitora.Font.Color := clRed;
      BtnMensagens.Enabled := False;
    end else begin
      MemoRecv.Lines.Add(ERRO_SRV);
      ShowMessage(ERRO_SRV);
    end;
  end else begin
    if (tc_startserver <> 0) then begin
      MemoRecv.Lines.Add(START_SRV);
      BtnIniciar.Caption := 'Parar';
      BtnMonitora.Font.Color := clGreen;
      BtnMensagens.Enabled := True;
      ListTerms.Clear;
      Timer3seg.Enabled := true;
      Timer100ms.Enabled := true;
    end else begin
      MemoRecv.Lines.Add(ERRO_SRV);
      Timer3seg.Enabled := false;
      Timer100ms.Enabled := false;
      ShowMessage(ERRO_SRV);
    end;
  end;
end;

procedure TFConsulta.BtnLimparMemoClick(Sender: TObject);
begin
  MemoRecv.Clear;
end;

procedure TFConsulta.BtnMensagensClick(Sender: TObject);
begin
  FConsulta.PC.ActivePageIndex := 1;
end;

procedure TFConsulta.BtnMonitoraClick(Sender: TObject);
begin
  FConsulta.PC.ActivePageIndex := 0;
end;

procedure TFConsulta.BtnMsgSendClick(Sender: TObject);
var
  Lin1: PAnsiChar;
  Lin2: PAnsiChar;
  Selected: String;
  Position: Integer;
  ID: stAddress;
begin
  Lin1:= PAnsichar(EdtLine1.Text);
  Lin2:= PAnsichar(EdtLine2.Text);
  if (ListTerms.ItemIndex < 0) then
  begin
    ShowMessage('Selecione um Terminal');
  end else begin
    Selected := ListTerms.Items.Strings[ListTerms.ItemIndex];
    Position := LastDelimiter(':', Selected);
    ID.Ip:= PAnsiChar(AnsiString(Copy(Selected,1,Position - 1)));
    ID.Socket:= StrToInt(Copy(Selected,Position+1,Length(Selected) - Position));
    bSendDisplayMsg(inet_Addr(ID.Ip),
                  Lin1,
                  Lin2,
                  StrToInt(EdtTimeEx.Text)
                  );
    MemoRecv.Lines.Add(String(ID.Ip) + ':' + IntToStr(ID.Socket) + ' -> ' +
      'Mensagem enviada ao Terminal');
  end;
end;

procedure TFConsulta.FormCreate(Sender: TObject);
  var
  ExeVer: String;
begin
  Exever := '';
  try
     ExeVer := GetEXEVersionData(Application.ExeName);
  except
  end;
  {$IFDEF WIN64}
  FConsulta.Caption := 'Consultador de Preço Pão da Vida - TANCA (Versão: '+ExeVer+' x64_lz)';
  {$ELSE}
  FConsulta.Caption := 'Consultador de Preço Pão da Vida - TANCA (Versao: '+ExeVer+' x86_lz)';

  {$ENDIF}

  if (CarregaDLL = false) then
  begin
    Application.Terminate;
    exit;
  end;

  SelTerm:= -1;
  FConsulta.PC.ActivePageIndex := 0;
  vInitialize;
  MemoRecv.Lines.Add('Versão da DLL: ' + String(dll_version));
  BtnMonitora.Font.Color := clRed;
  BtnMensagens.Enabled := False;

  try
     BtnIniciar.Click;   //iniciando o serviço no statup
  except
     MemoRecv.Lines.Add('Erro ao Tentar Iniciar Altomaticamente, Click em Iniciar.');
  end;

end;

procedure TFConsulta.ListTermsClick(Sender: TObject);
var
  i : integer;
begin
  with (Sender as TListBox) do begin
    i := ItemIndex-1;
    repeat
      inc(i);
      SelTerm := TabTerms.TabSock[i];
    until (TabTerms.TabSock[i]<>0) or (i>1023);
  end;
end;

procedure TFConsulta.MenuItem1Click(Sender: TObject);
begin
  FConsulta.Hide;
end;

procedure TFConsulta.Timer100msTimer(Sender: TObject);
var
  ID_Ip: DWORD;
  ID_Socket:  Word;
  Nbr : integer;
  BarCode: PAnsiChar;
  BarCodeBD: PAnsiChar;
  produto: PAnsiChar;
  preco: PAnsiChar;
  precoStr: String;
  preco_curr: String;
  length_preco_curr: integer;

begin

    BarCode := PChar(bReceiveBarcode(ID_Ip, ID_Socket, Nbr));

   if (BarCode <> '')  then
   begin
     try
        SQLQuery.close;
        SQLQuery.SQL.Clear;
        SQLQuery.SQL.Text := 'SELECT CODIGO, NOMEREDUZIDO, PRECO_VENDA FROM PRODUTO where CODIGO=' + quotedstr(String(BarCode));
        SQLQuery.Open;
        BarCodeBD := Pchar(SQLQuery.FieldByName('CODIGO').asString);
     except
       MemoRecv.Lines.add('Erro na Consulta.');
     end;
   end;


  if (BarCode <> '')  then
  begin
    if (string(BarCodeBD) = string(BarCode)) then
    begin
     produto := PAnsiChar(SQLQuery.FieldByName('NOMEREDUZIDO').asString);
     preco_curr:= SQLQuery.FieldByName('PRECO_VENDA').asString;
     length_preco_curr:= Length(preco_curr);
     if (preco_curr[length_preco_curr-2] = ',') then
     begin
        precoStr := PAnsiChar(Trim(EditUnidMon.Text) + ' ' + SQLQuery.FieldByName('PRECO_VENDA').asString);
     end else
     //1.0.0.3
     if (preco_curr[length_preco_curr-1] = ',') then
     begin
        precoStr := Trim(EditUnidMon.Text) + ' ' + SQLQuery.FieldByName('PRECO_VENDA').asString + '0';
     end else begin
        precoStr := Trim(EditUnidMon.Text) + ' ' + SQLQuery.FieldByName('PRECO_VENDA').asString + ',00';
     end;

       {

     if (Trim(SQLQuery.FieldByName('PRECO_VENDA').asString) <> '') then
     begin
       precoStr := precoStr + '|' + Trim(SQLQuery.FieldByName('PRECO_VENDA').asString);
       if (Trim(SQLQuery.FieldByName('PRECO_VENDA').asString) <> '') then
       begin
         precoStr := precoStr + '|' + Trim(SQLQuery.FieldByName('PRECO_VENDA').asString);
       end;
     end else
     if (Trim(SQLQuery.FieldByName('PRECO_VENDA').asString) <> '') then
     begin
       precoStr := precoStr + '||' + Trim(SQLQuery.FieldByName('PRECO_VENDA').asString);
     end;
     }

     preco := PAnsiChar(precoStr);
//1.0.0.3
     bSendProdPrice(ID_Ip, produto , preco);
     MemoRecv.Lines.Add(Inet_NtoA(ID_Ip) + ':' + IntToStr(ID_Socket) + ' -> ' +
      String(Barcode) + '|' + String(Produto) + '|' + String(Preco));
    end else begin
      bSendProdNotFound(ID_Ip);
      MemoRecv.Lines.Add(Inet_NtoA(ID_Ip) + ':' + IntToStr(ID_Socket) + ' -> ' +
          String(Barcode) + '|' + 'PRODUTO NAO ENCONTRADO');
    end;
  end;
end;

procedure TFConsulta.Timer3SegTimer(Sender: TObject);
var
  i: integer;
  sIP: PAnsiChar;
  SelTermBkp: integer;
  IdxLista: integer;

begin
  SelTermBkp:= -1;
  TabTerms := GetTabConectados(1);
  ListTerms.Clear;
  IdxLista := 0;
  for i:= 0 to TabTerms.NumSockConec-1 do
  begin
    if TabTerms.TabIP[i] <> 0 then
    begin
      sIP:= Inet_NtoA(TabTerms.TabIP[i]);
      if ((TabTerms.TabSock[i] = SelTerm) and (SelTermBkp = -1)) then
      begin
        SelTermBkp := IdxLista;
      end;
      inc(IdxLista);
      ListTerms.Items.Add(String(sIP) + ':' + IntToStr(TabTerms.TabSock[i]));
    end;
  end;
  ListTerms.ItemIndex := SelTermBkp;
  if (SelTermBkp = -1) then SelTerm := 0;
end;

function TFConsulta.CarregaDLL: Boolean;
var
  DLLHandle: cardinal;
  _DLL: String;
  ErrorMode: UINT;
const
  CRLF = chr(10)+chr(13);
begin
  _DLL := ExtractFilePath(Application.ExeName) + VP_DLL;
  if (fileexists(ExtractFilePath(Application.ExeName) + VP_DLL)) then
  begin
    if (DLLHandle > 32) then
    begin
      FreeLibrary(DLLHandle);
    end;
    ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS); // disable OS error messages
    try
      DLLHandle := LoadLibrary(PAnsiChar(_DLL));
    finally
      SetErrorMode(ErrorMode);
    end;

    ErrorMode := SetErrorMode(0); // enable OS error messages

    if (DLLHandle <= 32) then
    begin
      MessageBox(0, PAnsiChar('Erro ao carregar a DLL: ' + _DLL), 'Erro!', MB_OK);
      result := false;
    end
    else
    begin
//------------------------------------------------------------------------------
      //dll_v3
      GetTabConectados  := GetProcAddress(DLLHandle, 'GetTabConectados');
      Inet_NtoA         := GetProcAddress(DLLHandle, 'Inet_NtoA');
      vInitialize       := GetProcAddress(DLLHandle, 'vInitialize');
      tc_startserver    := GetProcAddress(DLLHandle, 'tc_startserver');
      dll_version       := GetProcAddress(DLLHandle, 'dll_version');
      bTerminate        := GetProcAddress(DLLHandle, 'bTerminate');
      bSendDisplayMsg   := GetProcAddress(DLLHandle, 'bSendDisplayMsg');
      bSendProdNotFound := GetProcAddress(DLLHandle, 'bSendProdNotFound');
      bSendProdPrice    := GetProcAddress(DLLHandle, 'bSendProdPrice');
      bReceiveBarcode   := GetProcAddress(DLLHandle, 'bReceiveBarcode');

      bConnected        := GetProcAddress(DLLHandle, 'bConnected');
      bDisconnected     := GetProcAddress(DLLHandle, 'bDisconnected');
      bCloseTerminal    := GetProcAddress(DLLHandle, 'bCloseTerminal');
      Inet_Addr         := GetProcAddress(DLLHandle, 'Inet_Addr');
//------------------------------------------------------------------------------

      result := true;
    end;
  end else begin
    MessageBox(0, PAnsiChar(_DLL + ' nao esta presente'), 'Erro!', MB_OK);
    result := false;
  end;
end;

function TFConsulta.GetEXEVersionData(const FileName: string): String;
type
  PLandCodepage = ^TLandCodepage;
  TLandCodepage = record
    wLanguage,
    wCodePage: word;
  end;
var
  dummy,
  len: cardinal;
  buf, pntr: pointer;
  lang: string;
begin
  len := GetFileVersionInfoSize(PChar(FileName), dummy);
  if len = 0 then
    RaiseLastOSError;
  GetMem(buf, len);
  try
    if not GetFileVersionInfo(PChar(FileName), 0, len, buf) then
      RaiseLastOSError;

    if not VerQueryValue(buf, '\VarFileInfo\Translation\', pntr, len) then
      RaiseLastOSError;

    lang := Format('%.4x%.4x', [PLandCodepage(pntr)^.wLanguage, PLandCodepage(pntr)^.wCodePage]);

    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\FileVersion'), pntr, len){ and (@len <> nil)} then
       result := PChar(pntr);
  finally
    FreeMem(buf);
  end;
end;

end.
