defmodule PhxGraphqlWeb.PageController do
  use PhxGraphqlWeb, :controller
  import PhxGraphqlWeb.Router.Helpers
  require Logger
  alias PhxGraphql.User
  alias PhxGraphqlWeb.Session
  alias PhxGraphqlWeb.Guardian

  @claims %{typ: "access"}

  def index(conn, _params) do
    conn
    |> put_layout("page.html")
    |> render("index.html")
  end

  def login(conn, %{"username" => _user} = params) do
    case Session.authenticate(params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user)
        |> Guardian.Plug.sign_in(user, @claims)
        |> put_layout("page.html")
        |> redirect(to: app_path(conn, :index))

      {:error, _error} ->
        conn
        |> put_flash(:error, "Username or password were not correct")
        |> put_layout("page.html")
        |> render("login.html")
    end
  end

  def login(conn, %{}) do
    conn
    |> put_layout("page.html")
    |> render("login.html")
  end

  def login(conn, _params) do
    conn
    |> put_flash(:error, "Username or password were not correct")
    |> put_layout("page.html")
    |> render("login.html")
  end

  def forgot_password(conn, _params) do
    conn
    |> put_layout("page.html")
    |> render("forgot_password.html")
  end

  def signup(conn, %{"username" => _user} = params) do
    case User.create(params) do
      {:ok, user} ->
        Logger.debug("Got a user for login: #{inspect(user)}")

        conn
        |> put_session(:current_user, user)
        |> redirect(to: app_path(conn, :index))

      {:error, _error} ->
        case Session.authenticate(params) do
          {:ok, user} ->
            conn
            |> put_session(:current_user, user)
            |> Guardian.Plug.sign_in(user, @claims)
            |> redirect(to: app_path(conn, :index))

          {:error, _error} ->
            conn
            |> put_flash(:error, "Could not create account, please contact support")
            |> put_layout("page.html")
            |> render("signup.html")
        end
    end
  end

  def signup(conn, _params) do
    conn
    |> put_layout("page.html")
    |> render("signup.html", signup: get_session(conn, :signup))
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> redirect(to: "/")
  end
end
