unit Sistema.Model.Interfaces.Cadastro;

interface

uses
  Generics.Collections,
  Vcl.Forms, Sistema.Common, Sistema.Model.Interfaces.Entity;

Type
  iBaseCadastro = interface
    ['{A5269850-8DD9-473B-B22D-1ADEE436655F}']
    /// <summary>
    ///  Fun��o que inicia o controle do formul�rio;
    /// </summary>
    /// <returns>
    ///  Retorna a interface.
    /// </returns>
    function Iniciar: iBaseCadastro;
    /// <summary>
    ///  Controla as a��es dos bot�es pelo tipo de a��o enviada pelo TTIpoAcao.
    /// </summary>
    /// <param name="AeAcao">
    ///  Indica a a��o que ser� executada pelo formul�rio.
    /// </param>
    /// <returns>
    ///  Retorna a interface.
    /// </returns>
    function AcaoBtnEditor(const AeAcao: TTipoAcaoBotoes): iBaseCadastro;
    /// <summary>
    ///  Pegar o Entity do formul�rio
    /// </summary>
    /// <returns>
    ///  Retorna a interface.
    /// </returns>
    function PegarEntidade: iEntityBase;
  end;

implementation

end.
