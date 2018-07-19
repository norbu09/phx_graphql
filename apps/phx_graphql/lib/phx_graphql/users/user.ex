defmodule PhxGraphql.User do
  require Logger

  @db Application.get_env(:couchex, :db)

  def create(user) do
    Logger.error("create not implemented yet: #{inspect user}")
    {:error, :not_impl}
  end

  def get_user_by_id(id) do
    Couchex.Client.get(@db, id)
  end
end
