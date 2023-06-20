unit Sistema.Model.Interfaces.Cadastro;

interface

uses
  Generics.Collections,
  Vcl.Forms, Sistema.Common, Sistema.Model.Interfaces.Entity;

Type
  iBaseCadastro = interface
    ['{A5269850-8DD9-473B-B22D-1ADEE436655F}']
    /// <summary>
    ///  Função que inicia o controle do formulário;
    /// </summary>
    /// <returns>
    ///  Retorna a interface.
    /// </returns>
    function Iniciar: iBaseCadastro;
    /// <summary>
    ///  Controla as ações dos botões pelo tipo de ação enviada pelo TTIpoAcao.
    /// </summary>
    /// <param name="AeAcao">
    ///  Indica a ação que será executada pelo formulário.
    /// </param>
    /// <returns>
    ///  Retorna a interface.
    /// </returns>
    function AcaoBtnEditor(const AeAcao: TTipoAcaoBotoes): iBaseCadastro;
    /// <summary>
    ///  Pegar o Entity do formulário
    /// </summary>
    /// <returns>
    ///  Retorna a interface.
    /// </returns>
    function PegarEntidade: iEntityBase;
  end;

implementation

end.
