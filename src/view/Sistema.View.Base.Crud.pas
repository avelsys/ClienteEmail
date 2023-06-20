unit Sistema.View.Base.Crud;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, System.Actions,
  Vcl.ActnList, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids,
  Sistema.Model.Interfaces.Cadastro, Sistema.Controller.Base.Cadastro,
  Sistema.Model.Atributes,Sistema.Common;

type
  TfrmBaseCadastro = class(TForm)
    [TAtrPaginaControle]
    pgBaseCadasro: TPageControl;
    [TAtrPaginaListagem]
    tbsListagem: TTabSheet;
    [TAtrPaginaCadastro]
    tbsFormulario: TTabSheet;
    [TAtrGridBase]
    dbgListagem: TDBGrid;
    gpbDetalhes: TGroupBox;
    pnlSide: TPanel;
    btnCancelar: TButton;
    btnNovo: TButton;
    btnAlterar: TButton;
    btnExcluir: TButton;
    btnGravar: TButton;
    btnSair: TButton;
    stbFooter: TStatusBar;
    actBaseFormulario: TActionList;
    [TAtrAcaoBtns(taNovo)]
    actNovo: TAction;
    [TAtrAcaoBtns(taEditar)]
    actAlterar: TAction;
    [TAtrAcaoBtns(taExcluir)]
    actExcluir: TAction;
    [TAtrAcaoBtns(taGravar)]
    actGravar: TAction;
    [TAtrAcaoBtns(taCancelar)]
    actCancelar: TAction;
    [TAtrAcaoBtns(taListagem)]
    actSair: TAction;
    hitBalao: TBalloonHint;
    [TAtrDataSet]
    [TAtrDataSource]
    procedure FormCreate(Sender: TObject);
    procedure actNovoExecute(Sender: TObject);
    procedure actAlterarExecute(Sender: TObject);
    procedure actExcluirExecute(Sender: TObject);
    procedure actGravarExecute(Sender: TObject);
    procedure actCancelarExecute(Sender: TObject);
    procedure actSairExecute(Sender: TObject);
    [TEventoAtributes('cep','OnExit')]
    procedure ConsultarCep(Sender: TObject);
  private
    FoCadastroController: iBaseCadastro;

  end;

implementation

uses
  Sistema.Entity.Cliente;

{$R *.dfm}

procedure TfrmBaseCadastro.actAlterarExecute(Sender: TObject);
begin
  FoCadastroController.AcaoBtnEditor(taEditar);
end;

procedure TfrmBaseCadastro.actCancelarExecute(Sender: TObject);
begin
  FoCadastroController.AcaoBtnEditor(taCancelar);
end;

procedure TfrmBaseCadastro.actExcluirExecute(Sender: TObject);
begin
  FoCadastroController.AcaoBtnEditor(taExcluir);
end;

procedure TfrmBaseCadastro.actGravarExecute(Sender: TObject);
begin
  FoCadastroController.AcaoBtnEditor(taGravar);
  oEntityCliente.EnviarEmailXML(dbgListagem.DataSource.DataSet);
end;

procedure TfrmBaseCadastro.actNovoExecute(Sender: TObject);
begin
  FoCadastroController.AcaoBtnEditor(taNovo);
end;

procedure TfrmBaseCadastro.actSairExecute(Sender: TObject);
begin
  FoCadastroController.AcaoBtnEditor(taSair);
end;

procedure TfrmBaseCadastro.ConsultarCep(Sender: TObject);
begin
  oEntityCliente.ConultarCEP(Sender);
end;

procedure TfrmBaseCadastro.FormCreate(Sender: TObject);
begin
  FoCadastroController := TCadastroController<TEntityCliente>.New(Self);
  FoCadastroController.Iniciar;
end;

end.
