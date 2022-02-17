defmodule AssinanteTest do
  use ExUnit.Case
  doctest Assinante

  setup do
    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test "%Assinante{}" do
    nome = "Teste"
    numero = "123"
    cpf = "123"
    plano = %Prepago{}

    expected_response = %Assinante{
      cpf: "123",
      nome: "Teste",
      numero: "123",
      plano: %Prepago{}
    }

    response = %Assinante{cpf: cpf, nome: nome, numero: numero, plano: plano}

    assert response == expected_response
  end

  describe "cadastrar/3" do
    test "cria uma conta prepago" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :prepago

      response = Assinante.cadastrar(nome, numero, cpf, plano)

      expected_response = {:ok, "Assinante Teste cadastrado(a) com sucesso."}

      assert response == expected_response
    end

    test "erro numero já existente" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :prepago

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)
      response = Assinante.cadastrar(nome, numero, cpf, plano)

      expected_response = {:error, "Já existe um assinante com este número."}

      assert response == expected_response
    end
  end

  describe "buscar_assinante/1" do
    test "sem informar o :all, apenas o número" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :prepago

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      response = Assinante.buscar_assinante(numero)

      expected_response =
        {:ok,
         %Assinante{
           cpf: "123",
           nome: "Teste",
           numero: "123",
           plano: %Prepago{}
         }}

      assert response == expected_response
    end
  end

  describe "buscar_assinante/2" do
    test "informando o :all" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :prepago

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      response = Assinante.buscar_assinante(numero, :all)

      expected_response =
        {:ok,
         %Assinante{
           cpf: "123",
           nome: "Teste",
           numero: "123",
           plano: %Prepago{}
         }}

      assert response == expected_response
    end

    test "prepago" do
      nome = "Teste"
      numero = "123"
      cpf = "123"

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, :prepago)

      response = Assinante.buscar_assinante(numero, :prepago)

      expected_response =
        {:ok,
         %Assinante{
           cpf: "123",
           nome: "Teste",
           numero: "123",
           plano: %Prepago{}
         }}

      assert response == expected_response
    end

    test "pospago" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :pospago

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      response = Assinante.buscar_assinante(numero, :pospago)

      expected_response =
        {:ok,
         %Assinante{
           cpf: "123",
           nome: "Teste",
           numero: "123",
           plano: %Pospago{}
         }}

      assert response == expected_response
    end
  end

  describe "remover/1" do
    test "sucesso ao remover pospago" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :pospago

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      expected_response = {:ok, "Usuário Teste removido com sucesso."}

      response = Assinante.remover(numero)

      assert response == expected_response
    end

    test "sucesso ao remover prepago" do
      nome = "Teste"
      numero = "123"
      cpf = "123"
      plano = :prepago

      {:ok, _mensagem} = Assinante.cadastrar(nome, numero, cpf, plano)

      expected_response = {:ok, "Usuário Teste removido com sucesso."}

      response = Assinante.remover(numero)

      assert response == expected_response
    end
  end
end
