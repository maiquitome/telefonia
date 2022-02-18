defmodule PospagoTest do
  use ExUnit.Case
  doctest Pospago

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
      plano = :pospago
      duracao = 5
      data = ~U[2021-01-01 20:17:37.569123Z]

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      expected_response = {:ok, "Chamada feita com sucesso. Duração: 5 minutos"}
      response = Pospago.fazer_chamada(numero, data, duracao)
      assert response == expected_response

      {:ok, assinante} = Assinante.buscar_assinante(numero)

      assert %Assinante{
               chamadas: [
                 %Chamada{
                   data: ~U[2021-01-01 20:17:37.569123Z],
                   duracao: 5
                 }
               ]
             } = assinante
    end
  end

  describe "imprimir_conta/3" do
    test "contas do mês" do
      nome = "Maiqui"
      numero = "5477889911"
      cpf = "12345678911"
      plano = :pospago
      data = DateTime.utc_now()
      data_anterior = ~U[2021-01-01 20:17:37.569123Z]
      duracao_chamada = 3

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      {:ok, _mensagem} = Pospago.fazer_chamada(numero, data_anterior, duracao_chamada + 1)
      {:ok, _mensagem} = Pospago.fazer_chamada(numero, data, duracao_chamada)
      {:ok, _mensagem} = Pospago.fazer_chamada(numero, data, duracao_chamada)
      {:ok, _mensagem} = Pospago.fazer_chamada(numero, data, duracao_chamada)


      {:ok, assinante} = Assinante.buscar_assinante(numero)

      assert assinante.numero == numero
      assert Enum.count(assinante.chamadas) == 4

      {:ok, assinante_imprimrir_conta} = Pospago.imprimir_conta(data.month, data.year, numero)

      chamadas = Enum.count(assinante_imprimrir_conta.chamadas)

      assert assinante_imprimrir_conta.numero == numero
      assert chamadas == 3

      custo_minuto = 1.40
      valor_por_chamada = duracao_chamada * custo_minuto
      valor_total = chamadas * valor_por_chamada

      assert assinante_imprimrir_conta.plano.valor == valor_total
    end
  end
end
