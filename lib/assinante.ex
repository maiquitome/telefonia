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
  - plano: prepago ou pospago.

  ## Exemplos

      iex> Assinante.cadastrar("Maiqui Tomé", "99339944", "12345678911", :prepago)
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
  def cadastrar(nome, numero, cpf, :prepago) do
    inserir_novo(nome, numero, cpf, %Prepago{})
  end

  def cadastrar(nome, numero, cpf, :pospago) do
    inserir_novo(nome, numero, cpf, %Pospago{})
  end

  def cadastrar(_nome, _numero, _cpf, plano) do
    {:error, "Plano `:#{plano}` desconhecido. Informe :prepago ou :pospago."}
  end

  defp inserir_novo(nome, numero, cpf, plano)
       when is_binary(nome)
       when is_binary(numero)
       when is_binary(cpf)
       when is_atom(plano) do
    if existe_assinante?(numero) do
      {:error, "Já existe um assinante com este número."}
    else
      assinante = %Assinante{nome: nome, numero: numero, cpf: cpf, plano: plano}

      plano_atom = pega_plano(assinante)

      with assinantes = [] <- read(plano_atom) do
        todos_e_mais_o_novo_assinante = assinantes ++ [assinante]

        write(todos_e_mais_o_novo_assinante, plano_atom)
        {:ok, "Assinante #{nome} cadastrado(a) com sucesso."}
      end
    end
  end

  def remover(numero) do
    with {:ok, assinante = %Assinante{}} <- buscar_assinante(numero) do
      case assinante.plano.__struct__ do
        Prepago ->
          write(assinantes_prepago() -- [assinante], pega_plano(assinante))
          {:ok, "Usuário #{assinante.nome} removido com sucesso."}

        Pospago ->
          write(assinantes_pospago() -- [assinante], pega_plano(assinante))
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

  defp pega_plano(assinante) when is_struct(assinante) do
    case assinante.plano.__struct__ do
      Prepago -> :prepago
      Pospago -> :pospago
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
