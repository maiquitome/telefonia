defmodule Assinante do
  @moduledoc """
  Módulo para cadastro de assinantes `prepago` e `pospago`.

  A função mais utilizada é a função `cadastrar/4`
  """

  defstruct nome: nil, numero: nil, cpf: nil, plano: nil

  @assinantes %{prepago: "pre.txt", pospago: "pos.txt"}

  @doc """
  Cadastra um assinante `prepago` ou `pospago`

  ## Parametros

  - nome: Nome completo da pessoa que está assinando o plano.
  - numero: Número único.
  - cpf: CPF da pessoa que está assinando o plano.
  - plano: Opcional -> prepago ou pospago. Caso não seje informado o default é prepago.

  ## Exemplos

      iex> Assinante.cadastrar("Maiqui Tomé", "99339944", "12345678911")
      {:ok, "Assinante Maiqui Tomé cadastrado(a) com sucesso."}

      iex> Assinante.cadastrar("Mike Wazowski", "12312331", "12345678911", :pospago)
      {:ok, "Assinante Mike Wazowski cadastrado(a) com sucesso."}

      iex> Assinante.cadastrar("Mike Wazowski", "12312331", "12345678911", :outro)
      {:error, "Plano `:outro` desconhecido. Informe :prepago ou :pospago."}

  """
  @spec cadastrar(
          nome :: String.t(),
          numero :: String.t(),
          cpf :: String.t(),
          plano :: atom()
        ) ::
          {:ok, String.t()} | {:error, String.t()}
  def cadastrar(nome, numero, cpf, plano \\ :prepago)
      when is_binary(nome)
      when is_binary(numero)
      when is_binary(cpf)
      when is_atom(plano) do
    if existe_assinante?(numero) do
      {:error, "Já existe um assinante com este número."}
    else
      with assinantes = [] <- read(plano) do
        todos_e_mais_o_novo_assinante =
          assinantes ++
            [%Assinante{nome: nome, numero: numero, cpf: cpf, plano: plano}]

        write(todos_e_mais_o_novo_assinante, plano)
        {:ok, "Assinante #{nome} cadastrado(a) com sucesso."}
      end
    end
  end

  def remover(numero) do
    with {:ok, assinante = %Assinante{}} <- buscar_assinante(numero) do
      case assinante.plano do
        :prepago ->
          write(assinantes_prepago() -- [assinante], assinante.plano)
          {:ok, "Usuário #{assinante.nome} removido com sucesso."}

        :pospago ->
          write(assinantes_pospago() -- [assinante], assinante.plano)
          {:ok, "Usuário #{assinante.nome} removido com sucesso."}
      end
    end
  end

  def assinantes_prepago(), do: read(:prepago)
  def assinantes_pospago(), do: read(:pospago)
  def assinantes(), do: read(:prepago) ++ read(:pospago)

  def buscar_assinante(numero, key \\ :all) do
    case buscar(numero, key) do
      nil -> {:error, "User not found."}
      assinante -> {:ok, assinante}
    end
  end

  defp buscar(numero, :all), do: assinantes() |> filtro(numero)
  defp buscar(numero, :prepago), do: assinantes_prepago() |> filtro(numero)
  defp buscar(numero, :pospago), do: assinantes_pospago() |> filtro(numero)
  defp filtro(lista, numero), do: Enum.find(lista, &(&1.numero == numero))

  defp existe_assinante?(numero) when is_binary(numero) do
    with {:ok, _assinante = %Assinante{}} <- buscar_assinante(numero) do
      true
    else
      {:error, _reason} -> false
    end
  end

  defp write(lista_assinantes, plano)
       when is_list(lista_assinantes)
       when is_atom(plano) do
    File.write(@assinantes[plano], :erlang.term_to_binary(lista_assinantes))
  end

  defp read(plano) when is_atom(plano) do
    if plano != :pospago and plano != :prepago do
      {:error, "Plano `:#{plano}` desconhecido. Informe :prepago ou :pospago."}
    else
      case File.read(@assinantes[plano]) do
        {:error, :enoent} -> []
        {:ok, assinantes} -> :erlang.binary_to_term(assinantes)
      end
    end
  end
end
