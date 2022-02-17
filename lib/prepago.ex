defmodule Prepago do
  defstruct creditos: 0, recargas: []

  @preco_minuto 1.45

  def fazer_chamada(numero, data, duracao) do
    with {:ok, assinante = %Assinante{}} <- Assinante.buscar_assinante(numero) do
      custo = @preco_minuto * duracao

      saldo_suficiente = custo <= assinante.plano.creditos

      if saldo_suficiente do
        plano = %Prepago{assinante.plano | creditos: assinante.plano.creditos - custo}

        assinante = %Assinante{assinante | plano: plano}
        Chamada.registrar(assinante, data, duracao)

        {:ok, "A chamada custou #{custo}, agora você tem #{plano.creditos} de créditos"}
      else
        {:error, "Você não tem créditos para fazer a ligação, faça uma recarga"}
      end
    end
  end

  def imprimir_conta(mes, ano, numero) do
    Contas.imprimir(mes, ano, numero, :prepago)
  end
end
