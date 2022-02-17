defmodule PrepagoTest do
  use ExUnit.Case
  doctest Prepago

  setup do
    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "fazer_chamada/3" do
    test "sucesso" do
      nome = "Maiqui"
      numero = "5477889911"
      cpf = "12345678911"
      plano = :prepago
      minutos_consumidos = 3
      data = DateTime.utc_now()
      valor_recarga = 10

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      Recarga.nova(data, valor_recarga, numero)

      expected_response = {:ok, "A chamada custou 4.35, agora você tem 5.65 de créditos"}

      response = Prepago.fazer_chamada(numero, DateTime.utc_now(), minutos_consumidos)

      assert response == expected_response
    end

    test "sem créditos" do
      nome = "Maiqui"
      numero = "5477889911"
      cpf = "12345678911"
      plano = :prepago
      minutos_consumidos = 10

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      expected_response = {:error, "Você não tem créditos para fazer a ligação, faça uma recarga"}

      response = Prepago.fazer_chamada(numero, DateTime.utc_now(), minutos_consumidos)

      assert response == expected_response
    end
  end

  describe "imprimir_conta/3" do
    test "contas do mês" do
      nome = "Maiqui"
      numero = "5477889911"
      cpf = "12345678911"
      plano = :prepago
      data = DateTime.utc_now()
      data_anterior = ~U[2021-01-01 20:17:37.569123Z]
      valor_recarga = 10
      duracao_chamada = 3

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      {:ok, _mensagem} = Recarga.nova(data, valor_recarga, numero)
      {:ok, _mensagem} = Prepago.fazer_chamada(numero, data, duracao_chamada)

      {:ok, _mensagem} = Recarga.nova(data, valor_recarga, numero)
      {:ok, _mensagem} = Prepago.fazer_chamada(numero, data_anterior, duracao_chamada)

      {:ok, assinante} = Assinante.buscar_assinante(numero)

      assert assinante.numero == numero
      assert Enum.count(assinante.chamadas) == 2
      assert Enum.count(assinante.plano.recargas) == 2

      {:ok, assinante_conta} = Prepago.imprimir_conta(data.month, data.year, numero)

      assert assinante_conta.numero == numero
      assert Enum.count(assinante_conta.chamadas) == 1
      assert Enum.count(assinante_conta.plano.recargas) == 2
    end
  end
end
