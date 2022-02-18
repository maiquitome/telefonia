defmodule Pospago do
  defstruct valor: 0

  @custo_minuto 1.40

  def fazer_chamada(numero, data, duracao) do
    {:ok, assinante} = Assinante.buscar_assinante(numero, :pospago)

    Chamada.registrar(assinante, data, duracao)

    {:ok, "Chamada feita com sucesso. Duração: #{duracao} minutos"}
  end

  def imprimir_conta(mes, ano, numero) do
    {:ok, assinante} = Contas.imprimir(mes, ano, numero, :pospago)

    valor_total =
      Enum.reduce(assinante.chamadas, 0, fn chamada, acc ->
        acc + chamada.duracao * @custo_minuto
      end)

    {:ok, %Assinante{assinante | plano: %Pospago{valor: valor_total}}}
  end
end
