defmodule Telefonia do
  def cadastrar_assinante(nome, numero, cpf, plano) do
    Assinante.cadastrar(nome, numero, cpf, plano)
  end

  def remover_assinante(numero) do
    Assinante.remover(numero)
  end
end
