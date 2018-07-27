defmodule PhxGraphql.Things do
  @moduledoc """
  The Things context.
  """

  alias PhxGraphql.Things.Thing
  alias PhxGraphql.Users.User
  require Logger
  @db Application.get_env(:couchex, :db)

  @spec list_things() :: list(%Thing{})
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

      iex> PhxGraphql.Things.get_thing!(123)
      %Thing{}

      iex> PhxGraphql.Things.get_thing!(456)
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

      iex> PhxGraphql.Things.list_user_things("123abc")
      [%Thing{}]

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

      iex> PhxGraphql.Things.create_thing(%{field: value}, %User)
      {:ok, %Thing{}}

      iex> PhxGraphql.Things.create_thing(%{field: bad_value}, %User)
      {:error, :error}

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

      iex> PhxGraphql.Things.update_thing(%Thing, %{field: :new_value})
      {:ok, %Thing{}}

      iex> PhxGraphql.Things.update_thing(%Thing, %{field: :bad_value})
      {:error, :error}

  """
  def update_thing(%Thing{} = thing, attrs) do
    Logger.debug("update: #{inspect(thing)}: #{inspect(attrs)}")
    {:ok, struct(%Thing{}, attrs)}
  end

  @doc """
  Deletes a Thing.

  ## Examples

      iex> PhxGraphql.Things.delete_thing(%Thing{}, %User{})
      {:ok, %Thing{}}

      iex> PhxGraphql.Things.delete_thing(%Thing{}, %User{})
      {:error, :authentication_error}

  """
  def delete_thing(%{id: id, version: rev}, %User{id: user_id}) do
    case get_thing!(id) do
      %Thing{} = thing ->
        case thing.user == user_id do
          true -> 
            case delete_thing(%{"_id" => id, "_rev" => rev}) do
              true -> {:ok, thing}
              _ -> {:error, :version_mismatch}
            end
          _ -> {:error, :authentication_error}
        end
      _ -> {:error, :document_not_found}
    end
  end

  @doc """
  Returns a map for tracking thing changes.

  ## Examples

      iex> PhxGraphql.Things.change_thing(%Thing{})
      :ok

  """
  def change_thing(%Thing{} = thing) do
    Logger.debug("change: #{inspect(thing)}")
    :ok
  end


  ## internal plumbing ##

  defp delete_thing(doc) do
    case Couchex.Client.del(@db, doc) do
      {:ok, %{"ok" => true}} -> true
      _ -> false
    end
  end
end
