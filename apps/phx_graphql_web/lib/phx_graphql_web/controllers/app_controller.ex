defmodule PhxGraphqlWeb.AppController do
  use PhxGraphqlWeb, :controller
  require Logger

  def index(conn, _params) do
    props = %{
      token: Guardian.Plug.current_token(conn),
      user: get_session(conn, :current_user)
    }

    conn
    |> put_layout("app.html")
    |> render("index.html", props: props)
  end

  def profile(conn, %{"current_password" => curr_pass, "new_password" => new_pass}) do
    curr_user = get_session(conn, :current_user)
    Logger.debug("password update")

    case PhxGraphql.User.pw_update(curr_user, curr_pass, new_pass) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user)
        |> put_flash(:info, "Password successfully updated")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(curr_user), user: curr_user)

      _ ->
        conn
        |> put_flash(:error, "Password update failed")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(curr_user), user: curr_user)
    end
  end

  def profile(conn, %{"username" => _username, "company" => _company} = update) do
    Logger.debug("profile update")
    curr_user = get_session(conn, :current_user)
    update1 = Enum.reduce(update, %{}, fn {x, y}, z -> Map.put(z, String.to_atom(x), y) end)
    upd = Map.merge(curr_user, update1)

    case PhxGraphql.User.update(curr_user, upd) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user)
        |> put_flash(:info, "Profile successfully updated")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(user), user: user)

      error ->
        Logger.error("Password update (controller): #{inspect(error)}")

        conn
        |> put_flash(:error, "Profile update failed")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(curr_user), user: curr_user)
    end
  end

  def profile(conn, %{}) do
    curr_user = get_session(conn, :current_user)

    conn
    |> put_layout("app.html")
    |> render("profile.html", token: get_token(curr_user), user: curr_user)
  end

  def add_token(conn, _params) do
    curr_user = get_session(conn, :current_user)

    case PhxGraphql.User.add_token(curr_user) do
      {:ok, token} ->
        conn
        |> put_flash(:info, "Token successfully created")
        |> put_layout("app.html")
        |> render("profile.html", token: token, user: curr_user)

      _ ->
        conn
        |> put_flash(:error, "Token creation failed")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(curr_user), user: curr_user)
    end
  end

  def del_token(conn, %{"token" => token}) do
    curr_user = get_session(conn, :current_user)

    case PhxGraphql.User.del_token(curr_user, token) do
      {:ok, token} ->
        conn
        |> put_flash(:info, "Token successfully deleted")
        |> put_layout("app.html")
        |> render("profile.html", token: token, user: curr_user)

      _ ->
        conn
        |> put_flash(:error, "Token delete failed")
        |> put_layout("app.html")
        |> render("profile.html", token: get_token(curr_user), user: curr_user)
    end
  end

  def unauthenticated(conn, _params) do
    redirect(conn, to: "/")
  end

  defp get_token(user) do
    case PhxGraphql.User.get_token(user) do
      {:ok, token} -> token
      _ -> []
    end
  end
end
