defmodule PhxGraphqlWeb.AppController do
  use PhxGraphqlWeb, :controller
  require Logger

  def index(conn, _params) do
    initial_state = %{"phx_graphql" => get_session(conn, :user)}
    Logger.debug("initial state: #{inspect initial_state}")

    conn
    |> render("index.html", [props: initial_state])
  end
  
  def unauthenticated(conn, _params) do
    redirect(conn, to: "/")
  end

  
end
