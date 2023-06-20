unit Sistema.Model.Atributes;

interface
uses
  Rtti, Sistema.Model.Interfaces.Cadastro, Vcl.ComCtrls, Data.DB, Sistema.Common;

const
  csTAMANHO_PADRAO = 15;

Type
  TAtrConfiguraCampos = Class(TCustomAttribute)
  private
    FoTipoDado: TFieldType;
    FsLabel: string;
    FsNome: string;
    FiSize: Integer;
  public
    constructor Create(const AoTipoDado: TFieldType; const AsNome: string;
      const AsLabel: string; const AiSize: integer = csTAMANHO_PADRAO);
    /// <summary>
    ///  Seta o Label para o campo
    /// </summary>
    property oTipoDado: TFieldType read FoTipoDado write FoTipoDado;
    /// <summary>
    ///  Seta o nome do campo
    /// </summary>
    property sNome: string read FsNome write FsNome;
    /// <summary>
    ///  Seta o Label para o campo
    /// </summary>
    property sLabel: string read FsLabel write FsLabel;
    /// <summary>
    ///  Seta o Tamanho para o campo
    /// </summary>
    property iSize: Integer read FiSize write FiSize;
  End;

  TAtrPaginaControle = Class(TCustomAttribute)
  public
    constructor Create;
  End;

  TAtrPaginaListagem = Class(TCustomAttribute)
  public
    constructor Create;
  End;

  TAtrPaginaCadastro = Class(TCustomAttribute)
  public
    constructor Create;
  End;

  TAtrAcaoBtns = Class(TCustomAttribute)
  private
    FAcaoBtn: TTipoAcaoBotoes;
  public
    constructor Create(const AAcaoBtn: TTipoAcaoBotoes);
    property AcaoBtn: TTipoAcaoBotoes read FAcaoBtn write FAcaoBtn;
  End;

  TAtrDataSet = Class(TCustomAttribute)
  public
    constructor Create;
  End;

  TAtrDataSource = Class(TCustomAttribute)
  public
    constructor Create;
  End;

  TAtrGridBase = Class(TCustomAttribute)
  public
    constructor Create;
  End;

  TEventoAtributes = class(TCustomAttribute)
  private
    FsNomeCampo: String;
    FsEvento: string;
  public
    constructor Create(const AsNomeCampo: String; const AsEvento: String);
    property sNomeCampo: String read FsNomeCampo write FsNomeCampo;
    property sEvento: string read FsEvento write FsEvento;
  end;



implementation

{ TAtrConfiguraFields }

constructor TAtrConfiguraCampos.Create(const AoTipoDado: TFieldType; const AsNome: string;
      const AsLabel: string; const AiSize: integer = csTAMANHO_PADRAO);
begin
  FoTipoDado:= AoTipoDado;
  FsLabel:= AsLabel;
  FsNome:= AsNome;
  FiSize:= AiSize;
end;

{ TAtrPaginaControle }

constructor TAtrPaginaControle.Create;
begin

end;

{ TAtrPaginaListagem }

constructor TAtrPaginaListagem.Create;
begin

end;

{ TAtrPaginaCadastro }

constructor TAtrPaginaCadastro.Create;
begin

end;

{ TAtrAcaoBtns }

constructor TAtrAcaoBtns.Create(const AAcaoBtn: TTipoAcaoBotoes);
begin
  FAcaoBtn := AAcaoBtn;
end;

{ TAtrDataSource }

constructor TAtrDataSource.Create;
begin

end;

{ TAtrDataSet }

constructor TAtrDataSet.Create;
begin

end;

{ TAtrGridBase }

constructor TAtrGridBase.Create;
begin

end;

{ TEventoAtributes }

constructor TEventoAtributes.Create(const AsNomeCampo, AsEvento: String);
begin
  FsNomeCampo := AsNomeCampo;
  FsEvento := AsEvento;
end;

end.
