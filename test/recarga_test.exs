defmodule RecargaTest do
  use ExUnit.Case
  doctest Recarga

  setup do
    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "recarga/3" do
    test "sucesso" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :prepago
      data = DateTime.utc_now()
      valor_recarga = 30

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      expected_response = {:ok, "Recarga realizada com sucesso."}
      response = Recarga.nova(data, valor_recarga, numero)
      assert response == expected_response

      {:ok, assinante} = Assinante.buscar_assinante("123", :prepago)

      expected_response = 30
      response = assinante.plano.creditos
      assert response == expected_response

      expected_response = 1
      response = Enum.count(assinante.plano.recargas)
      assert response == expected_response
    end
  end
end
