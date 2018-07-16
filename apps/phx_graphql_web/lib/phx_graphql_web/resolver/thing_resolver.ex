defmodule PhxGraphqlWeb.ThingResolver do
  alias PhxGraphql.Things
  require Logger

  def all_things(_root, _args, _info) do
    things = Things.list_things()
    {:ok, things}
  end

  def create_thing(_root, args, %{context: %{current_user: user}}) do
    # TODO: add detailed error message handling later
    Logger.debug("User for create: #{user}")

    case Things.create_thing(args) do
      {:ok, thing} ->
        {:ok, thing}

      _error ->
        {:error, "could not create thing"}
    end
  end

  def create_thing(_root, _args, _info) do
    {:error, "Access denied"}
  end

  def find_thing(_parent, %{id: id}, _resolution) do
    case Things.get_thing!(id) do
      {:error, error} ->
        {:error, error}

      thing ->
        {:ok, thing}
    end
  end
end
