defmodule PhxGraphqlWeb.ThingTest do
  use ExUnit.Case


  test "allThings []" do
    list = """
    query {
      allThings {
        id,
        description
      }
    }
    """
    |> Absinthe.run(PhxGraphqlWeb.Schema)

    assert list == {:ok, %{data: %{"allThings" => []}}}
  end
end

