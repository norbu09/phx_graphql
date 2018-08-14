defmodule PhxGraphql.Things do
  @moduledoc """
  The Things context.
  """

  alias PhxGraphql.Types.Thing
  alias PhxGraphql.Types.User
  require Logger
  @db Application.get_env(:couchex, :db)

  @spec list_things() :: list(%Thing{}) | [] | {:error, term()}
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
  Gets a single thing and either return a %Thing or a error tuple.
  """
  @spec get_thing!(String.t()) :: %Thing{} | {:error, term()}
  def get_thing!(id) do
    case Couchex.Client.get(@db, id) do
      {:ok, thing} ->
        Thing.new(thing)

      {:error, {_status, %{"error" => error}}} ->
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Returns the list of things belonging to one user.
  """
  @spec list_user_things(String.t()) :: [] | [%Thing{}, ...] | {:error, term()}
  def list_user_things(user) do
    case Couchex.Client.get(@db, %{view: "things/by_user"}, %{
           "key" => user,
           "include_docs" => true
         }) do
      {:ok, []} ->
        []

      {:ok, things} ->
        things
        |> Enum.map(fn x -> Thing.new(x) end)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Creates a %Thing. This needs a user record to assign a user property to the %Thing record.
  """
  @spec create_thing(map(), %User{}) :: {:ok, %Thing{}} | {:error, term()}
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

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  TODO: still needs implementing
  Takes two %Thing records and updates the first one with the second one.
  """
  def update_thing(%Thing{} = thing, attrs) do
    Logger.debug("update: #{inspect(thing)}: #{inspect(attrs)}")
    {:ok, struct(%Thing{}, attrs)}
  end

  @doc """
  Deletes a %Thing given its ID, version and a user record that has a corresponding user_id.
  """
  @spec delete_thing(map(), %User{}) :: {:ok, %Thing{}} | {:error, atom()}
  def delete_thing(%{id: id, version: rev}, %User{id: user_id}) do
    case get_thing!(id) do
      %Thing{} = thing ->
        case thing.user == user_id do
          true ->
            case delete_thing(%{"_id" => id, "_rev" => rev}) do
              true -> {:ok, thing}
              _ -> {:error, :version_mismatch}
            end

          _ ->
            {:error, :authentication_error}
        end

      _ ->
        {:error, :document_not_found}
    end
  end

  ## internal plumbing ##

  @spec delete_thing(map()) :: true | false
  defp delete_thing(doc) do
    case Couchex.Client.del(@db, doc) do
      {:ok, %{"ok" => true}} -> true
      _ -> false
    end
  end
end
