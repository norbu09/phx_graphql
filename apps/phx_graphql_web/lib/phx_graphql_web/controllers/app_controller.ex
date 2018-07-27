defmodule PhxGraphqlWeb.AppController do
  use PhxGraphqlWeb, :controller
  require Logger

  def index(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("index.html", user: get_session(conn, :current_user))
  end

  def profile(conn, %{}) do
    conn
    |> put_layout("app.html")
    |> render("profile.html", token: ["foo123", "bar123"], user: get_session(conn, :current_user))
  end
  def profile(conn, params) do
    PhxGraphql.User.update(params)
    conn
    |> put_layout("app.html")
    |> render("profile.html", token: ["foo123", "bar123"], user: get_session(conn, :current_user))
  end

  def unauthenticated(conn, _params) do
    redirect(conn, to: "/")
  end
end
