unit Sistema.Main.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, System.Actions, Vcl.ActnList,
  Vcl.ComCtrls, Sistema.View.Base.Crud;

type
  TfrmMain = class(TForm)
    mmnMain: TMainMenu;
    mnCadastro: TMenuItem;
    mnCliente: TMenuItem;
    aclAcoesMenuMain: TActionList;
    actCliente: TAction;
    stbInformaSistema: TStatusBar;
    procedure actClienteExecute(Sender: TObject);
  private
    procedure CriarFormulario(const AoFormularioBase: TFormClass);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.actClienteExecute(Sender: TObject);
begin
  CriarFormulario(TfrmBaseCadastro);
end;

procedure TfrmMain.CriarFormulario(const AoFormularioBase: TFormClass);
var
  oFormulario: TForm;
begin
  oFormulario := AoFormularioBase.Create(nil);
  try
    oFormulario.ShowModal;
  finally
    FreeAndNil(oFormulario);
  end;
end;

end.
