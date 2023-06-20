unit Sistema.Entity.Cliente;

interface

uses
  Sistema.Model.Interfaces.Entity, Sistema.Model.Atributes, Sistema.Common,
  Data.DB, REST.Types, REST.Client, REST.Response.Adapter, System.SysUtils,
  System.JSON, System.Variants, Vcl.DBCtrls, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,
  IniFiles, IdSMTP, IdMessage, IdText, IdSSLOpenSSL, System.Classes,
  IdExplicitTLSClientServerBase, IdAttachmentFile, Vcl.Dialogs,IdAttachment ;

type
  TDadosCep = record
    sCep: string;
    sLogradouro: string;
    sNumero: string;
    sComplemento: string;
    sBairro: string;
    sCidade: string;
    sEstado: string;
    sPais: string;
  end;

  TEntityCliente = class(TInterfacedObject, iEntityBase)
  private
    FsCPF: string;
    FsCep: string;
    FsNumero: string;
    FsIdentidade: string;
    FsComplemento: string;
    FsNome: string;
    FsCidade: string;
    FsTelefone: string;
    FsLogradouro: string;
    FsBairro: string;
    FsEmail: string;
    FsEstado: string;
    FsPais: string;
    FoBaseDados: TDataSet;
    function ValidarDadosCEP(const AsCep: string): TDadosCep;
    procedure MontarDocumentoXML(AoBaseDados: TDataSet) ;
    procedure EnviarEmail(const AAssunto, ADestino, AAnexo: String; ACorpo: TStrings);
  public
    procedure SetBaseDados(AoBaseDados: TDataSet);
    procedure ConultarCEP(ASender: TObject);
    procedure EnviarEmailXML(AoBaseDados: TDataSet);

    [TAtrConfiguraCampos(ftString, 'nome','Nome Completo',50)]
    property sNome: string read FsNome write FsNome;
    [TAtrConfiguraCampos(ftString, 'identidade','RG',15)]
    property sIdentidade: string read FsIdentidade write FsIdentidade;
    [TAtrConfiguraCampos(ftString, 'cpf','CPF',11)]
    property sCPF: string read FsCPF write FsCPF;
    [TAtrConfiguraCampos(ftString, 'telefone','Celular',11)]
    property sTelefone: string read FsTelefone write FsTelefone;
    [TAtrConfiguraCampos(ftString, 'email','E-Mail',50)]
    property sEmail: string read FsEmail write FsEmail;
    [TAtrConfiguraCampos(ftString, 'cep','CEP',8)]
    property sCep: string read FsCep write FsCep;
    [TAtrConfiguraCampos(ftString, 'logradouro','Logradouro',50)]
    property sLogradouro: string read FsLogradouro write FsLogradouro;
    [TAtrConfiguraCampos(ftString, 'numero','Número',10)]
    property sNumero: string read FsNumero write FsNumero;
    [TAtrConfiguraCampos(ftString, 'complemento','Complemento',30)]
    property sComplemento: string read FsComplemento write FsComplemento;
    [TAtrConfiguraCampos(ftString, 'bairro','bairro',30)]
    property sBairro: string read FsBairro write FsBairro;
    [TAtrConfiguraCampos(ftString, 'cidade','cidade',30)]
    property sCidade: string read FsCidade write FsCidade;
    [TAtrConfiguraCampos(ftString, 'uf','UF',2)]
    property sEstado: string read FsEstado write FsEstado;
    [TAtrConfiguraCampos(ftString, 'pais','Pais',30)]
    property sPais: string read FsPais write FsPais;
  end;

var
  oEntityCliente: TEntityCliente;

implementation

resourcestring
  csUSUARIO_EMAIL = 'avelinoalessandro@gmail.com';
  csSENHA_EMAIL = 'mmtfhpcjlkukyepz';
  csCONTENTTYPE_XML = 'application/xml;';
  csINLINE = 'inline';
  csBASE64 = 'base64';
  csNOME_EMAIL = 'E-Mail Resposta do Cliente';
  csCONTENTTYPE_MIXED = 'multipart/mixed';
  csEMAIL_ORIGEM = 'avelinoalessandro@gmail.com';

const
  csNOMEARQUIVO_XML = 'DadosClience.xml';
  csCONTENTTYPE_TEXT_HTML = 'text/html';
  csCHARSET = 'ISO-8859-1';
  csBODY_EMAIL = 'Texto em html';
  csSMTP_HOST = 'smtp.gmail.com';
  csPORTA = 587;

{ TEntityCliente }

procedure TEntityCliente.ConultarCEP(ASender: TObject);
var
  oDadosCep: TDadosCep;
  oEdiCep: TDBEdit;
  oDataSet: TDataSet;
begin
  oEdiCep := (ASender as TDBEdit);
  oDataSet:= oEdiCep.DataSource.DataSet;
  oDadosCep := ValidarDadosCEP(oEdiCep.Text);
  if not Assigned(oDataSet) then
    raise Exception.Create('Erro não há base de dados configurada.');

  if Assigned(oDataSet.FindField('cep')) then
    oDataSet.FindField('cep').Value :=  oDadosCep.sCep;

  if Assigned(oDataSet.FindField('logradouro')) then
    oDataSet.FindField('logradouro').Value :=  oDadosCep.sLogradouro;

  if Assigned(oDataSet.FindField('complemento')) then
    oDataSet.FindField('complemento').Value :=  oDadosCep.sComplemento;

  if Assigned(oDataSet.FindField('bairro')) then
    oDataSet.FindField('bairro').Value :=  oDadosCep.sBairro;

  if Assigned(oDataSet.FindField('cidade')) then
    oDataSet.FindField('cidade').Value :=  oDadosCep.sCidade;

  if Assigned(oDataSet.FindField('uf')) then
    oDataSet.FindField('uf').Value :=  oDadosCep.sEstado;

  if Assigned(oDataSet.FindField('pais')) then
    oDataSet.FindField('pais').Value :=  oDadosCep.sPais;


end;

procedure TEntityCliente.SetBaseDados(AoBaseDados: TDataSet);
begin
  FoBaseDados := AoBaseDados;
end;

function TEntityCliente.ValidarDadosCEP(const AsCep: string): TDadosCep;
const
  csURL_CONSULTA_CEP_VIACEP = 'https://viacep.com.br/ws/%s/json/';

var
  oRequest: TRESTRequest;
  oClientRequest: TRESTClient;
  oResponse: TRESTResponse;
  oJsonDadosCep: TJSONObject;
begin
  oRequest := TRESTRequest.Create(nil);
  try
    oRequest.Method := TRESTRequestMethod.rmGET;
    oClientRequest:= TRESTClient.Create(nil);
    oClientRequest.Params.AddHeader('Content-Type', 'application/json');
    try
      oClientRequest.BaseURL := format(csURL_CONSULTA_CEP_VIACEP, [AsCep]);
      oRequest.Client := oClientRequest;
      oResponse:= TRESTResponse.Create(nil);
      try
        oRequest.Response := oResponse;
        try
          oRequest.Execute;
          oJsonDadosCep := (TJSONValue.ParseJSONValue(oResponse.Content) as TJSONObject);
          result.sCep := oJsonDadosCep.GetValue<string>('cep');
          result.sLogradouro := oJsonDadosCep.GetValue<string>('logradouro');
          result.sComplemento := oJsonDadosCep.GetValue<string>('complemento');
          result.sBairro := oJsonDadosCep.GetValue<string>('bairro');
          result.sCidade := oJsonDadosCep.GetValue<string>('localidade');
          result.sEstado:= oJsonDadosCep.GetValue<string>('uf');
          result.sPais:= 'Brasil';
        except On E:Exception do
          raise Exception.Create(Format('Erro ao validar os dados do Cep %s.',[E.Message]));
        end;
      finally
        oResponse.Free;
      end;
    finally
      oClientRequest.Free;
    end;
  finally
    oRequest.Free;
  end;
end;

procedure TEntityCliente.EnviarEmailXML(AoBaseDados: TDataSet);
begin
  MontarDocumentoXML(AoBaseDados);
end;

procedure TEntityCliente.MontarDocumentoXML(AoBaseDados: TDataSet) ;
var
  oDocXML: IXMLDocument;
  oRootNode: IXMLNode;
  oField: TField;
  sPathArquivoXML: string;
  sBodyEmail: TStrings;
  sEmailDestino: string;
begin
  sBodyEmail:= TStringList.Create;
  oDocXML   := NewXMLDocument;
  oDocXML.Options := [doNodeAutoIndent];
  oRootNode := oDocXML.AddChild('Cliente');
  for oField in AoBaseDados.Fields do
  begin
    oRootNode.AddChild(oField.FieldName).Text := oField.Value;
    if oField.FieldName = 'email' then
      sEmailDestino := oField.Value;
  end;
  if sEmailDestino.IsEmpty then
    raise Exception.Create('E-Mail de destino não informado.');

  sPathArquivoXML:= format('%s\%s',[GetCurrentDir,csNOMEARQUIVO_XML]);
  oDocXML.SaveToFile(sPathArquivoXML);
  sBodyEmail.Add('teste de envio de email');
  EnviarEmail('Resposta ao Cliente',sEmailDestino,sPathArquivoXML, sBodyEmail);

end;

procedure TEntityCliente.EnviarEmail(const AAssunto, ADestino, AAnexo: String; ACorpo: TStrings);
var
  oSMTP: TIdSMTP;
  oMsg: TIdMessage;
  oText: TIdText;
  oIdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
  oIdAttachmentFile: TIdAttachmentFile;
begin
  oMsg := TIdMessage.Create(nil);
  try
    oMsg.MessageParts.Clear();
    oMsg.From.Address := csEMAIL_ORIGEM;
    oMsg.From.Name := csNOME_EMAIL;
    oMsg.Recipients.EMailAddresses := ADestino;
    oMsg.ContentType := csCONTENTTYPE_MIXED;
    oMsg.Body.AddStrings(ACorpo);
    oMsg.Subject := AAssunto;

    oIdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create();
    try
      oIdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
      oIdSSLIOHandlerSocket.SSLOptions.Mode := sslmClient;

      oText := TIdText.Create (oMsg.MessageParts, Nil);
      try
        oText.ContentType := csCONTENTTYPE_TEXT_HTML;
        oText.CharSet := csCHARSET;
        oText.Body.Text := csBODY_EMAIL;

        oSMTP := TIdSMTP.Create(nil);
        try
          oSMTP.IOHandler := oIdSSLIOHandlerSocket;
          oSMTP.Host := csSMTP_HOST;
          oSMTP.Port := csPORTA;
          oSMTP.AuthType := satDefault;
          oSMTP.UseTLS := utUseImplicitTLS;
          oSMTP.Username := csUSUARIO_EMAIL;
          oSMTP.Password := csSENHA_EMAIL;
          oSMTP.Connect;
          oSMTP.Authenticate;
          if FileExists(AAnexo) then
          begin
            oIdAttachmentFile := TIdAttachmentFile.Create(oMsg.MessageParts, AAnexo);
            oIdAttachmentFile.ContentType := csCONTENTTYPE_XML;
            oIdAttachmentFile.FileName := csNOMEARQUIVO_XML;
            oIdAttachmentFile.ContentDisposition := csINLINE;
            oIdAttachmentFile.ContentTransfer := csBASE64;
          end;

          if oSMTP.Connected then
          begin
            try
              oSMTP.Send(oMsg);
            except on E:Exception do
              begin
                ShowMessage('Erro ao tentar enviar: ' + E.Message);
              end;
            end;
          end;

          if oSMTP.Connected then
            oSMTP.Disconnect;

        finally
            oSMTP.Free;
        end;
      finally
        oText.Free;
      end;
    finally
      oIdSSLIOHandlerSocket.Free;
    end;
  finally
    oMsg.Free;
  end;

end;

end.
