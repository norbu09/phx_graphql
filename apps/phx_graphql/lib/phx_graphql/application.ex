defmodule PhxGraphql.Application do
  @moduledoc """
  The PhxGraphql Application Service.

  The phx_graphql system business domain lives in this application.

  Exposes API to clients such as the `PhxGraphqlWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # start CouchDB migration task
    Task.async(fn -> CouchViewManager.migrate() end)

    Supervisor.start_link([], strategy: :one_for_one, name: PhxGraphql.Supervisor)
  end
end
