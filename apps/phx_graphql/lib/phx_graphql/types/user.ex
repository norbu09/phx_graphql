defmodule PhxGraphql.Types.User do
  require Logger

  @db Application.get_env(:couchex, :db)
  @record [:id, :username, :created, :company, :version]
  @behaviour Access

  defstruct @record

  def new(%{"doc" => map}) do
    new(map)
  end

  def new(map) do
    m2 =
      map
      |> Map.put("id", map["_id"])
      |> Map.put("version", map["_rev"])

    rec = Enum.reduce(@record, %{}, fn x, y -> Map.put(y, x, m2[x] || m2[Atom.to_string(x)]) end)
    struct(%__MODULE__{}, rec)
  end

  def update(user) do
    case Couchex.Client.get(@db, user.id) do
      {:ok, doc} ->
        upd =
          Enum.reduce(@record, doc, fn x, y ->
            Map.put(y, Atom.to_string(x), user[x] || doc[Atom.to_string(x)])
          end)
          |> Map.put("_id", user.id)
          |> Map.put("_rev", user.version)
          |> Map.delete("id")
          |> Map.delete("version")

        case Couchex.Client.put(@db, upd) do
          {:ok, insert} ->
            {:ok, %{new(upd) | id: insert["id"], version: insert["rev"]}}

          error ->
            error
        end

      _ ->
        {:error, :authentication_error}
    end
  end

  def update(user, update) do
    case Couchex.Client.get(@db, user.id) do
      {:ok, doc} ->
        Couchex.Client.put(@db, Map.merge(doc, update))

      _ ->
        {:error, :authentication_error}
    end
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

  defimpl Enumerable, for: __MODULE__ do
    def count(map) do
      {:ok, map_size(map)}
    end

    def member?(map, {key, value}) do
      {:ok, match?(%{^key => ^value}, map)}
    end

    def member?(_map, _other) do
      {:ok, false}
    end

    def slice(map) do
      {:ok, map_size(map), &Enumerable.List.slice(:maps.to_list(map), &1, &2)}
    end

    def reduce(map, acc, fun) do
      reduce_list(:maps.to_list(map), acc, fun)
    end

    defp reduce_list(_, {:halt, acc}, _fun), do: {:halted, acc}

    defp reduce_list(list, {:suspend, acc}, fun),
      do: {:suspended, acc, &reduce_list(list, &1, fun)}

    defp reduce_list([], {:cont, acc}, _fun), do: {:done, acc}
    defp reduce_list([h | t], {:cont, acc}, fun), do: reduce_list(t, fun.(h, acc), fun)
  end
end
