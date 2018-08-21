defmodule PhxGraphqlWeb.AppController do
  use PhxGraphqlWeb, :controller
  import PhxGraphqlWeb.Router.Helpers
  require Logger

  def index(conn, _params) do
    props = %{
      token: Guardian.Plug.current_token(conn),
      user: get_session(conn, :current_user),
      base: app_path(conn, :index)
    }

    conn
    |> put_layout("app.html")
    |> render("index.html", props: props)
  end

end
