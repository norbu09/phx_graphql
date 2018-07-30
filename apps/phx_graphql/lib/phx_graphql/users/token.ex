defmodule PhxGraphql.Users.Token do
  require Logger

  @record [:token, :created]
  @behaviour Access

  defstruct @record

  def new(%{"doc" => %{"token" => list}}) do
    new(list)
  end

  def new(map) when is_map(map) do
    new([map])
  end

  def new(list) do
    list
    |> Enum.map(fn x -> to_record(x) end)
  end

  defp to_record(map) do
    rec = Enum.reduce(@record, %{}, fn x, y -> Map.put(y, x, map[Atom.to_string(x)]) end)
    struct(%__MODULE__{}, rec)
  end

  # Access implementation ###
  def fetch(struct, key), do: Map.fetch(struct, key)
  def get(struct, key, default \\ nil), do: Map.get(struct, key, default)

  def get_and_update(struct, key, fun) when is_function(fun, 1) do
    current = get(struct, key)

    case fun.(current) do
      {get, update} ->
        {get, Map.put(struct, key, update)}

      :pop ->
        pop(struct, key)

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  def pop(struct, key, default \\ nil) do
    case fetch(struct, key) do
      {:ok, old_value} ->
        {old_value, Map.put(struct, key, nil)}

      :error ->
        {default, struct}
    end
  end
end
