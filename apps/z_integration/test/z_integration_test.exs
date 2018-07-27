defmodule ZIntegrationTest do
  @db Application.get_env(:couchex, :db)

  use ExUnit.Case
  doctest ZIntegration

  setup_all do
    on_exit fn -> cleanup() end
  end

  test "greets the world" do
    assert ZIntegration.hello() == :world
  end


  defp cleanup do
    IO.puts("removing test DB")
    Couchex.Client.delete_db(@db)
  end

end
