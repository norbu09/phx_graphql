defmodule PhxGraphqlWeb.Router do
  use PhxGraphqlWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:set_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(PhxGraphqlWeb.Context)
  end

  pipeline :app do
    plug(:ensure_authenticated)
    plug(PhxGraphqlWeb.Guardian.AuthPipeline)
  end

  scope "/", PhxGraphqlWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/register", PageController, :signup)
    post("/register", PageController, :signup)

    get("/login", PageController, :login)
    post("/login", PageController, :login)

    get("/forgot-password", PageController, :forgot_password)
    post("/forgot-password", PageController, :forgot_password)

    post("/logout", PageController, :logout)
  end

  scope "/api" do
    pipe_through(:api)

    forward("/", Absinthe.Plug, schema: PhxGraphqlWeb.Schema)
  end

  scope "/graphiql" do
    pipe_through(:api)

    forward("/", Absinthe.Plug.GraphiQL, schema: PhxGraphqlWeb.Schema)
  end

  scope "/app", PhxGraphqlWeb do
    pipe_through([:browser, :app])

    get("/", AppController, :index)
    get("/*path", AppController, :index)
  end

  def set_current_user(conn, _) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
  end

  def ensure_authenticated(conn, _) do
    case get_session(conn, :current_user) do
      %PhxGraphql.Types.User{username: _user} ->
        conn

      _ ->
        conn |> put_flash(:error, "You must be logged in") |> redirect(to: "/")
    end
  end
end
