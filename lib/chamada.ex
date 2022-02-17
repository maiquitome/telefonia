defmodule Chamada do
  defstruct data: nil, duracao: nil

  def registrar(assinante, data, duracao) do
    chamadas = assinante.chamadas ++ [%Chamada{data: data, duracao: duracao}]

    assinante_atualizado = %Assinante{assinante | chamadas: chamadas}

    Assinante.atualizar(assinante.numero, assinante_atualizado)
  end
end
