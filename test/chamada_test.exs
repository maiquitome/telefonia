defmodule ChamadaTest do
  use ExUnit.Case
  doctest Chamada

  test "struct" do
    assert %Chamada{data: DateTime.utc_now(), duracao: 30}.duracao == 30
  end
end
