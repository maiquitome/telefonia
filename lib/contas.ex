defmodule Contas do
  def imprimir(mes, ano, numero, plano)
      when is_number(mes)
      when is_number(ano)
      when is_binary(numero)
      when is_atom(plano) do
    {:ok, assinante} = Assinante.buscar_assinante(numero)
    chamadas_do_mes = busca_elementos_mes(assinante.chamadas, mes, ano)

    cond do
      plano == :prepago ->
        recargas_do_mes = busca_elementos_mes(assinante.plano.recargas, mes, ano)
        plano = %Prepago{assinante.plano | recargas: recargas_do_mes}
        {:ok, %Assinante{assinante | chamadas: chamadas_do_mes, plano: plano}}

      plano == :pospago ->
        {:ok, %Assinante{assinante | chamadas: chamadas_do_mes}}
    end
  end

  def busca_elementos_mes(elementos, mes, ano) do
    Enum.filter(elementos, &(&1.data.year == ano and &1.data.month == mes))
  end
end
