defmodule Recarga do
  defstruct data: nil, valor: nil

  def nova(data, valor, numero) do
    {:ok, assinante} = Assinante.buscar_assinante(numero, :prepago)

    plano = assinante.plano
    creditos = plano.creditos + valor
    recargas = plano.recargas ++ [%Recarga{data: data, valor: valor}]

    plano = %Prepago{plano | creditos: creditos, recargas: recargas}

    assinante = %Assinante{assinante | plano: plano}

    {:ok, _mensagem} = Assinante.atualizar(numero, assinante)

    {:ok, "Recarga realizada com sucesso."}
  end
end
