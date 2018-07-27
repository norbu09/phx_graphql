defmodule PhxGraphql.Users.User do
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

    rec = Enum.reduce(@record, %{}, fn x, y -> Map.put(y, x, m2[Atom.to_string(x)]) end)
    struct(%__MODULE__{}, rec)
  end

  def update(user) do
    case Couchex.Client.get(@db, user.id) do
      {:ok, doc} ->

      upd = Enum.reduce(@record, doc, fn x, y -> Map.put(y, Atom.to_string(x), user[x]) end)
            |> Map.put("_id", user.id)
            |> Map.put("_rev", user.version)
            |> Map.delete("id")
            |> Map.delete("version")
      Couchex.Client.put(@db, upd)
      _ -> 
        {:error, :authentication_error}
    end
  end

  # Access implementation ###
  @impl Access
  def fetch(struct, key), do: Map.fetch(struct, key)
  @impl Access
  def get(struct, key, default \\ nil) do
    case struct do
      %{^key => value} -> value
      _else -> default
    end
  end
  @impl Access
  def put(struct, key, val) do
    if Map.has_key?(struct, key) do
      Map.put(struct, key, val)
    else
      struct
    end
  end
  @impl Access
  def delete(struct, key) do
    put(struct, key, %__MODULE__{}[key])
  end
  @impl Access
  def get_and_update(struct, key, fun) when is_function(fun, 1) do
    current = get(struct, key)
    case fun.(current) do
      {get, update} ->
        {get, put(struct, key, update)}
      :pop ->
        {current, delete(struct, key)}
      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end
  @impl Access
  def pop(struct, key, default \\ nil) do
    val = get(struct, key, default)
    updated = delete(struct, key)
    {val, updated}
  end
  defoverridable [fetch: 2, get: 3, put: 3, delete: 2, get_and_update: 3, pop: 3]


end

alias PhxGraphql.Users.User

defimpl Enumerable, for: User do
  def count(users) when is_list(users) do
    Enum.count(users)
  end
  def count(user) when is_map(user) do
    1
  end

  def member?(_, _), do: {:error, __MODULE__}

  def slice(_), do: {:error, __MODULE__}

  def reduce(_stream, _acc, _fun) do
    {:error, __MODULE__}
  end
end

defimpl Collectable, for: User do
  def into(_stream) do
    {:error, __MODULE__}
  end
end
