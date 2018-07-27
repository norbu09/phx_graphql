defmodule PhxGraphql.Things do
  @moduledoc """
  The Things context.
  """

  @db Application.get_env(:couchex, :db)
  alias PhxGraphql.Things.Thing
  require Logger

  @doc """
  Returns the list of things.

  ## Examples

      iex> list_things()
      [%Thing{}, ...]

  """
  def list_things do
    case Couchex.Client.get(@db, %{view: "things/all"}, %{"include_docs" => true}) do
      {:ok, things} ->
        things
        |> Enum.map(fn x -> Thing.new(x) end)

      {:error, {{:http_status, 404}, _}} ->
        []

      error ->
        error
    end
  end

  @doc """
  Gets a single thing.

  ## Examples

      iex> get_thing!(123)
      %Thing{}

      iex> get_thing!(456)
      ** (NoResultsError)

  """
  def get_thing!(id) do
    case Couchex.Client.get(@db, id) do
      {:ok, thing} ->
        Thing.new(thing)

      {:error, {_status, %{"error" => error}}} ->
        {:error, error}

      error ->
        error
    end
  end

  @doc """
  Returns the list of things belonging to one user.

  ## Examples

      iex> list_user_things()
      [%Thing{}, ...]

  """
  def list_user_things(user) do
    case Couchex.Client.get(@db, %{view: "things/by_user"}, %{"key" => user, "include_docs" => true}) do
      {:ok, []} ->
        []

      {:ok, things} ->
        things
        |> Enum.map(fn x -> Thing.new(x) end)

      error ->
        error
    end
  end

  @doc """
  Creates a thing.

  ## Examples

      iex> create_thing(%{field: value}, %User)
      {:ok, %Thing{}}

      iex> create_thing(%{field: bad_value}, %User)
      {:error, error}

  """
  def create_thing(attrs, user) do
    doc =
      attrs
      |> Map.put("type", "thing")
      |> Map.put("user", user.id)

    Logger.debug("create: #{inspect(doc)}")

    case Couchex.Client.put(@db, doc) do
      {:ok, %{"id" => id}} ->
        thing = Thing.new(Map.put(doc, "_id", id))
        Logger.debug("Got insert: #{inspect(thing)}")
        {:ok, thing}

      error ->
        error
    end
  end

  @doc """
  Updates a thing.

  ## Examples

      iex> update_thing(thing, %{field: new_value})
      {:ok, %Thing{}}

      iex> update_thing(thing, %{field: bad_value})
      {:error, %Changeset{}}

  """
  def update_thing(%Thing{} = thing, attrs) do
    Logger.debug("update: #{inspect(thing)}: #{inspect(attrs)}")
    {:ok, struct(%Thing{}, attrs)}
  end

  @doc """
  Deletes a Thing.

  ## Examples

      iex> delete_thing(thing)
      {:ok, %Thing{}}

      iex> delete_thing(thing)
      {:error, %Changeset{}}

  """
  def delete_thing(%Thing{} = thing) do
    Logger.debug("delete: #{inspect(thing)}")
    {:ok, thing}
  end

  @doc """
  Returns a map for tracking thing changes.

  ## Examples

      iex> change_thing(thing)
      %Thing{}}

  """
  def change_thing(%Thing{} = thing) do
    Logger.debug("change: #{inspect(thing)}")
    :ok
  end
end
