program Sistema;

uses
  Vcl.Forms,
  Sistema.Main.View in 'src\view\Sistema.Main.View.pas' {frmMain},
  Sistema.Entity.Cliente in 'src\controller\entity\Sistema.Entity.Cliente.pas',
  Sistema.Model.Atributes in 'src\model\Sistema.Model.Atributes.pas',
  Sistema.View.Base.Crud in 'src\view\Sistema.View.Base.Crud.pas' {frmBaseCadastro},
  Sistema.Model.Interfaces.Cadastro in 'src\model\Sistema.Model.Interfaces.Cadastro.pas',
  Sistema.Controller.Base.Cadastro in 'src\controller\Sistema.Controller.Base.Cadastro.pas',
  Sistema.Model.Interfaces.Entity in 'src\model\Sistema.Model.Interfaces.Entity.pas',
  Sistema.Common in 'src\Class\Sistema.Common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
