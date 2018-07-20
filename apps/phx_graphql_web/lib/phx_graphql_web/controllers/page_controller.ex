defmodule PhxGraphqlWeb.PageController do
  use PhxGraphqlWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, %{"username" => _user} = params) do
    case PhxGraphqlWeb.Session.authenticate(params) do
      {:ok, user} ->
        conn
        |> put_session(:user, user)
        |> redirect(to: "/app")
      {:error, _error} ->
        conn
        |> put_flash(:error, "Username or password were not correct")
        |> render("login.html")
    end
  end
  def login(conn, %{}) do
    conn
    |> render("login.html")
  end
  def login(conn, _params) do
    conn
    |> put_flash(:error, "Username or password were not correct")
    |> render("login.html")
  end

  def forgot_password(conn, _params) do
    conn
    |> render("forgot_password.html")
  end

  def signup(conn, %{"username" => _user} = params) do
    case PhxGraphql.User.create(params) do
      {:ok, user} ->
        Logger.debug("Got a user for login: #{inspect user}")
        conn
        |> put_session(:user, user)
        |> redirect(to: "/app")
      {:error, _error} ->
        case PhxGraphqlWeb.Session.authenticate(params) do
          {:ok, user} ->
            conn
            |> put_session(:user, user)
            |> redirect(to: "/app")
          {:error, _error} ->
            conn
            |> put_flash(:error, "Could not create account, please contact support")
            |> render("signup.html")
        end
    end
  end
  def signup(conn, _params) do
    conn
    |> render("signup.html", signup: get_session(conn, :signup))
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user)
    |> redirect(to: "/")
  end
  
end
