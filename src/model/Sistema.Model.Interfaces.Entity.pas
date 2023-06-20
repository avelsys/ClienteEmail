unit Sistema.Model.Interfaces.Entity;

interface

uses
  Data.DB;

Type
  iEntityBase = interface
    ['{3839F14C-B8A4-4481-938F-7F4B6D1BE262}']
    procedure SetBaseDados(AoBaseDados: TDataSet);
    procedure EnviarEmailXML(AoBaseDados: TDataSet);
  end;

implementation

end.
