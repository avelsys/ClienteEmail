unit Sistema.Controller.Base.Cadastro;

interface

uses
  Sistema.Model.Interfaces.Cadastro, Vcl.Forms, System.Classes, Sistema.Model.Interfaces.Entity,
  System.Rtti, System.SysUtils, Vcl.StdCtrls, Vcl.ComCtrls, TypInfo,  DBClient, Vcl.DBCtrls,
  System.Generics.Collections, Vcl.ActnList, Data.DB, Vcl.DBGrids, Sistema.Common, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

const
  csPOSICAO_TOP_EDITORES_INICIAL = 30;
  csPOSICAO_TOP_EDITORES = 50;
  csPOSICAO_LEFT_EDITORES = 25;
  csESPACO_ENTRE_EDITORES = 25;
  csESPACO_ENTRE_LABEL_EDIT = 15;

  csPREFIXO_EDIT = 'edt%s';

type
  TDadosEdit = record
    FoTipoDado: TFieldType;
    FsLabel: string;
    FsNome: string;
    FiSize: Integer;
  end;
  TDicionarioBtnAcao = TDictionary<TTipoAcaoBotoes,TAction>;
  TCadastroController<T: iEntityBase, constructor> = class(TInterfacedObject, iBaseCadastro)
  private
    FoEntidade: T;
    FoFormularioBase: TForm;
    FoPaginaControle: TPageControl;
    FoPaginaListagem: TTabSheet;
    FoPaginaCadastro: TTabSheet;
    FoListaBtnAcoes: TDicionarioBtnAcao;
    FoDataSetBase: TFDMemtable;
    FoDataSource: TDataSource;
    foDBGridBase: TDBGrid;
    constructor Create(AOwner: TForm);
    procedure PegarPaginas;
    procedure ConstruirEditores;
    procedure CriarEdits(AoAtributos: TCustomAttribute);
    procedure ConstruirEdit(const AoDadosEdit: TDadosEdit);
    procedure ConfigurarPaginaInicial;
    procedure PegarAcaoBtns;
    procedure ComtrolarAcaoBtns(const AeAcao: TTipoAcaoBotoes);
    procedure PegarGridBase;
    procedure ConfigurarBaseDados;
    procedure ConfigurarGridListagem;
    function Novo: iBaseCadastro;
    function Editar: iBaseCadastro;
    function Excluir: iBaseCadastro;
    function Gravar: iBaseCadastro;
    function Cancela: iBaseCadastro;
    function Sair: iBaseCadastro;
    procedure ConstruirLabel(AiTamanhoEdit: Integer; const AoDadosEdit: TDadosEdit);
    procedure ColetarMetodoEditAtributos;
  public
    class function New(AOwner: TForm): iBaseCadastro;
    function Iniciar: iBaseCadastro;
    function AcaoBtnEditor(const AeAcao: TTipoAcaoBotoes): iBaseCadastro;
    function PegarEntidade: iEntityBase;

  end;

var
  iPosicaoEdtorTop: Integer;
  iPosicaoEdtorLeft: Integer;

implementation

uses
  Sistema.Model.Atributes;

{ TCadastroController<T> }

function TCadastroController<T>.Novo: iBaseCadastro;
begin
      FoDataSource.DataSet.Append;
end;

function TCadastroController<T>.Editar: iBaseCadastro;
begin
  FoDataSource.DataSet.Edit;
end;

function TCadastroController<T>.Excluir: iBaseCadastro;
begin
  FoDataSource.DataSet.Delete;
end;

function TCadastroController<T>.Gravar: iBaseCadastro;
begin
  try
    FoDataSource.DataSet.Post;
  Except on E:Exception do
    raise Exception.Create(Format('Erro ao Gravar: %s',[E.Message]));
  end;
end;

function TCadastroController<T>.Cancela: iBaseCadastro;
begin
  FoDataSource.DataSet.Cancel;
end;

function TCadastroController<T>.Sair: iBaseCadastro;
begin
  FoFormularioBase.Close;
end;

function TCadastroController<T>.Iniciar: iBaseCadastro;
begin
  result := Self;
  PegarPaginas;
  PegarAcaoBtns;
  ConfigurarPaginaInicial;
  PegarGridBase;
  ConfigurarBaseDados;
  ConfigurarGridListagem;
  ConstruirEditores;
  ColetarMetodoEditAtributos;
  ComtrolarAcaoBtns(taListagem);
end;

procedure TCadastroController<T>.ConstruirEdit(const AoDadosEdit: TDadosEdit);
var
  oEdit: TDBEDit;
  iTamanhoEspaco, iTamanhoEdit: Integer;
begin
  if not Assigned(FoPaginaCadastro) then
    raise Exception.Create(Format('Erro na configuração das páginas',[]));

  iTamanhoEspaco := FoPaginaCadastro.Width - iPosicaoEdtorLeft;
  iTamanhoEdit :=  (AoDadosEdit.FiSize * 10);
  if iTamanhoEspaco < iTamanhoEdit then
  begin
    iPosicaoEdtorTop := iPosicaoEdtorTop + csPOSICAO_TOP_EDITORES;
    iPosicaoEdtorLeft := csPOSICAO_LEFT_EDITORES;
  end;
  ConstruirLabel(iTamanhoEdit, AoDadosEdit);
  oEdit:= TDBEDit.Create(FoPaginaCadastro);
  oEdit.Parent := FoPaginaCadastro;
  oEdit.Name := Format('edt%s',[AoDadosEdit.FsNome]);
  oEdit.DataSource := FoDataSource;
  oEdit.DataField := AoDadosEdit.FsNome;
  oEdit.Width := iTamanhoEdit;
  oEdit.Top := iPosicaoEdtorTop + csESPACO_ENTRE_LABEL_EDIT;
  oEdit.Left := iPosicaoEdtorLeft;
  oEdit.Text := EmptyStr;
  iPosicaoEdtorLeft := iPosicaoEdtorLeft + (oEdit.Width + csESPACO_ENTRE_EDITORES)
end;

procedure TCadastroController<T>.ConstruirEditores;
var
  oRTTIContexto: TRttiContext;
  oRTTITipo: TRttiType;
  oRTTIPropriedade: TRttiProperty;
  oRTTIAtributo: TCustomAttribute;
  oAtributo: TAtrConfiguraCampos;
  Info: PTypeInfo;
  oField: TField;
begin
  oRTTIContexto:= TRttiContext.Create;
  try
    Info := System.TypeInfo(T);
    oRTTITipo := oRTTIContexto.GetType(Info);
    for oRTTIPropriedade in oRTTITipo.GetProperties do
      for oRTTIAtributo in oRTTIPropriedade.GetAttributes do
         if oRTTIAtributo is TAtrConfiguraCampos then
            CriarEdits(oRTTIAtributo)
  finally
    oRTTIContexto.Free;
  end;
end;

procedure TCadastroController<T>.PegarPaginas;
var
  oRTTIContexto: TRttiContext;
  oRTTITipo: TRttiType;
  oRTTIField: TRttiField;
  oRTTIAtributo: TCustomAttribute;
begin
  oRTTIContexto:= TRttiContext.Create;
  try
    oRTTITipo := oRTTIContexto.GetType(FoFormularioBase.ClassInfo);
    for oRTTIField in oRTTITipo.GetFields do
      for oRTTIAtributo in oRTTIField.GetAttributes do
      begin
        if oRTTIAtributo is TAtrPaginaControle then
          FoPaginaControle := (oRTTIField.GetValue(FoFormularioBase).AsObject as TPageControl);
        if oRTTIAtributo is TAtrPaginaListagem then
          FoPaginaListagem := (oRTTIField.GetValue(FoFormularioBase).AsObject as TTabSheet);
        if oRTTIAtributo is TAtrPaginaCadastro then
          FoPaginaCadastro := (oRTTIField.GetValue(FoFormularioBase).AsObject as TTabSheet);
      end;

  finally
    oRTTIContexto.Free;
  end;
end;

procedure TCadastroController<T>.PegarAcaoBtns;
var
  oRTTIContexto: TRttiContext;
  oRTTITipo: TRttiType;
  oRTTIField: TRttiField;
  oRTTIAtributo: TCustomAttribute;
  oAcao: TAction;
  eTipoAcao: TTipoAcaoBotoes;
begin
  oRTTIContexto:= TRttiContext.Create;
  try
    oRTTITipo := oRTTIContexto.GetType(FoFormularioBase.ClassInfo);
    for oRTTIField in oRTTITipo.GetFields do
      for oRTTIAtributo in oRTTIField.GetAttributes do
        if oRTTIAtributo is TAtrAcaoBtns then
        begin
          oAcao := (oRTTIField.GetValue(FoFormularioBase).AsObject as TAction);
          eTipoAcao := TAtrAcaoBtns(oRTTIAtributo).AcaoBtn;
          FoListaBtnAcoes.Add(eTipoAcao,oAcao);
        end;
  finally
    oRTTIContexto.Free;
  end;
end;

function TCadastroController<T>.PegarEntidade: iEntityBase;
begin
  result := FoEntidade;
end;

procedure TCadastroController<T>.PegarGridBase;
var
  oRTTIContexto: TRttiContext;
  oRTTITipo: TRttiType;
  oRTTIField: TRttiField;
  oRTTIAtributo: TCustomAttribute;
begin
  oRTTIContexto:= TRttiContext.Create;
  try
    oRTTITipo := oRTTIContexto.GetType(FoFormularioBase.ClassInfo);
    for oRTTIField in oRTTITipo.GetFields do
      for oRTTIAtributo in oRTTIField.GetAttributes do
         if oRTTIAtributo is TAtrGridBase then
            foDBGridBase := (oRTTIField.GetValue(FoFormularioBase).AsObject as TDBGrid);
  finally
    oRTTIContexto.Free;
  end;
end;

constructor TCadastroController<T>.Create(AOwner: TForm);
begin
  FoFormularioBase:= AOwner;
  FoEntidade := T.Create;
  FoDataSetBase:= TFDMemtable.Create(AOwner);
  FoDataSetBase.CachedUpdates := True;
  FoDataSource:= TDataSource.Create(AOwner);

  iPosicaoEdtorTop:= csPOSICAO_TOP_EDITORES_INICIAL;
  iPosicaoEdtorLeft:= csPOSICAO_LEFT_EDITORES;
  FoListaBtnAcoes := TDicionarioBtnAcao.Create;
end;

procedure TCadastroController<T>.CriarEdits(AoAtributos: TCustomAttribute);
var
  oAtrConfiguraCampos: TAtrConfiguraCampos;
  oDadosEdit: TDadosEdit;
begin
  oAtrConfiguraCampos:= TAtrConfiguraCampos(AoAtributos);
  oDadosEdit.FoTipoDado := oAtrConfiguraCampos.oTipoDado;
  oDadosEdit.FsNome := oAtrConfiguraCampos.sNome;
  oDadosEdit.FsLabel := oAtrConfiguraCampos.sLabel;
  oDadosEdit.FiSize := oAtrConfiguraCampos.iSize;

  case oAtrConfiguraCampos.oTipoDado of
    ftString: ConstruirEdit(oDadosEdit);
  end;
end;

function TCadastroController<T>.AcaoBtnEditor(
  const AeAcao: TTipoAcaoBotoes): iBaseCadastro;
begin
  ComtrolarAcaoBtns(AeAcao);
end;

procedure TCadastroController<T>.ConstruirLabel(AiTamanhoEdit: Integer; const AoDadosEdit: TDadosEdit);
var
  oLabel: TLabel;
begin
  oLabel := TLabel.Create(FoPaginaCadastro);
  oLabel.Parent := FoPaginaCadastro;
  oLabel.Name := Format('lbl%s', [AoDadosEdit.FsNome]);
  oLabel.Caption := AoDadosEdit.FsLabel;
  oLabel.Width := AiTamanhoEdit;
  oLabel.Top := iPosicaoEdtorTop;
  oLabel.Left := iPosicaoEdtorLeft;
end;

procedure TCadastroController<T>.ComtrolarAcaoBtns(
  const AeAcao: TTipoAcaoBotoes);
begin
  FoPaginaControle.ActivePage := FoPaginaListagem;
  if (AeAcao in taModoEdicao) then
    FoPaginaControle.ActivePage := FoPaginaCadastro;

  FoListaBtnAcoes[taNovo].Enabled := (AeAcao in taModoListagem);
  FoListaBtnAcoes[taEditar].Enabled := (AeAcao in taModoListagem) and (not FoDataSetBase.IsEmpty);
  FoListaBtnAcoes[taGravar].Enabled := (AeAcao in taModoEdicao);
  FoListaBtnAcoes[taExcluir].Enabled := (AeAcao in taModoListagem) and (not FoDataSetBase.IsEmpty);
  FoListaBtnAcoes[taCancelar].Enabled := (AeAcao in taModoEdicao);

  case AeAcao of
    taNovo: Novo;
    taEditar: Editar;
    taExcluir:Excluir;
    taGravar:Gravar;
    taCancelar: Cancela;
    taSair: Sair;
  end;

end;

procedure TCadastroController<T>.ConfigurarBaseDados;
var
  oRTTIContexto: TRttiContext;
  oRTTITipo: TRttiType;
  oRTTIPropriedade: TRttiProperty;
  oRTTIAtributo: TCustomAttribute;
  oAtributo: TAtrConfiguraCampos;
  Info: PTypeInfo;
  oField: TField;
begin
  oRTTIContexto:= TRttiContext.Create;
  try
    Info := System.TypeInfo(T);
    oRTTITipo := oRTTIContexto.GetType(Info);
    for oRTTIPropriedade in oRTTITipo.GetProperties do
      for oRTTIAtributo in oRTTIPropriedade.GetAttributes do
      begin
         if oRTTIAtributo is TAtrConfiguraCampos then
         begin
            oAtributo:= TAtrConfiguraCampos(oRTTIAtributo);
            case oAtributo.otipodado of
              ftString:
                begin
                  oField := TStringField.Create(FoDataSetBase);
                  oField.FieldName := oAtributo.sNome;
                  oField.DisplayLabel := oAtributo.sLabel;
                  oField.FieldKind := fkData;
                  oField.Size := oAtributo.iSize;
                  oField.DataSet := FoDataSetBase;
                end;
            end;
         end;
      end;
    FoDataSetBase.CreateDataSet;
    FoDataSetBase.Open;
    FoDataSource.DataSet := FoDataSetBase;
    FoEntidade.SetBaseDados(FoDataSource.DataSet);
  finally
    oRTTIContexto.Free;
  end;
end;

procedure TCadastroController<T>.ConfigurarGridListagem;
var
  oRTTIContexto: TRttiContext;
  oRTTITipo: TRttiType;
  oRTTIPropriedade: TRttiProperty;
  oRTTIAtributo: TCustomAttribute;
  oAtributo: TAtrConfiguraCampos;
  Info: PTypeInfo;
  oColuma: TColumn;
begin
  oRTTIContexto:= TRttiContext.Create;
  try
    Info := System.TypeInfo(T);
    oRTTITipo := oRTTIContexto.GetType(Info);
    for oRTTIPropriedade in oRTTITipo.GetProperties do
      for oRTTIAtributo in oRTTIPropriedade.GetAttributes do
      begin
         if oRTTIAtributo is TAtrConfiguraCampos then
         begin
          oAtributo:= TAtrConfiguraCampos(oRTTIAtributo);
          oColuma:= foDBGridBase.Columns.Add;
          oColuma.FieldName := oAtributo.sNome;
          oColuma.Title.Caption := oAtributo.sLabel;
          oColuma.Width := (oAtributo.iSize * 10);
         end;
      end;
    foDBGridBase.DataSource := FoDataSource;
  finally
    oRTTIContexto.Free;
  end;
end;

procedure TCadastroController<T>.ConfigurarPaginaInicial;
begin
  FoPaginaListagem.TabVisible := False;
  FoPaginaCadastro.TabVisible := False;
  FoPaginaControle.ActivePage := FoPaginaListagem;
end;

procedure TCadastroController<T>.ColetarMetodoEditAtributos;
var
  oRTTIContexto: TRttiContext;
  oRTTITipo, oRTTITipoEdit: TRttiType;
  oRTTIMetodo: TRttiMethod;
  oRTTIProperty: TRttiProperty;
  oRTTIAtributo: TCustomAttribute;
  oHandlerMetodo: TMethod;
  oNomeComponent: string;
  oLabelEditComponente: TDBEdit;
begin
  oRTTIContexto:= TRttiContext.Create;
  oRTTITipo := oRTTIContexto.GetType(FoFormularioBase.ClassType);
  for oRTTIMetodo in oRTTITipo.GetMethods do
    for oRTTIAtributo in oRTTIMetodo.GetAttributes do
      if oRTTIAtributo is TEventoAtributes then
      begin
        oNomeComponent := format(csPREFIXO_EDIT,[TEventoAtributes(oRTTIAtributo).sNomeCampo]);
        if Assigned(FoPaginaCadastro.FindComponent(oNomeComponent)) then
        begin
          oLabelEditComponente :=  TDBLabeledEdit(FoPaginaCadastro.FindComponent(oNomeComponent));
          oRTTITipoEdit := oRTTIContexto.GetType(oLabelEditComponente.ClassType);
          oRTTIProperty := oRTTITipoEdit.GetProperty(TEventoAtributes(oRTTIAtributo).sEvento);
          oHandlerMetodo.Code := oRTTIMetodo.CodeAddress;
          oHandlerMetodo.Data := oLabelEditComponente;
          oRTTIProperty.SetValue(oLabelEditComponente,TValue.From<TNotifyEvent>(TNotifyEvent(oHandlerMetodo)));
        end;
      end;
end;

class function TCadastroController<T>.New(AOwner: TForm): iBaseCadastro;
begin
  Result := Self.Create(AOwner);
end;

end.
