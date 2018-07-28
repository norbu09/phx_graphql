defmodule PhxGraphqlWeb.AppController do
  use PhxGraphqlWeb, :controller
  require Logger

  def index(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("index.html", user: get_session(conn, :current_user))
  end

  def profile(conn, %{"current_password" => curr_pass, "new_password" => new_pass}) do
    Logger.debug("password update")
    case PhxGraphql.User.pw_update(get_session(conn, :current_user), curr_pass, new_pass) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user)
        |> put_flash(:info, "Password successfully updated")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(), user: get_session(conn, :current_user))
      _ ->
        conn
        |> put_flash(:error, "Password update failed")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(), user: get_session(conn, :current_user))
    end
  end
  def profile(conn, %{"username" => _username, "company" => _company} = update) do
    Logger.debug("profile update")
    curr_user = get_session(conn, :current_user)
    update1 = Enum.reduce(update, %{}, fn({x, y}, z) -> Map.put(z, String.to_atom(x), y) end)
    upd = Map.merge(curr_user, update1)
    case PhxGraphql.User.update(curr_user, upd) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user)
        |> put_flash(:info, "Profile successfully updated")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(), user: user)
      error ->
        Logger.error("Password update (controller): #{inspect error}")
        conn
        |> put_flash(:error, "Profile update failed")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(), user: get_session(conn, :current_user))
    end
  end
  def profile(conn, %{}) do
    conn
    |> put_layout("app.html")
    |> render("profile.html", token: get_token(), user: get_session(conn, :current_user))
  end

  def unauthenticated(conn, _params) do
    redirect(conn, to: "/")
  end

  defp get_token do
    ["foo123", "bar123"]
  end
end
