defmodule PhxGraphqlWeb.Router do
  use PhxGraphqlWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug PhxGraphqlWeb.Guardian.AuthPipeline
  end

  pipeline :app do
    plug PhxGraphqlWeb.Guardian.AuthPipeline
  end


  scope "/", PhxGraphqlWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    get  "/register", PageController, :signup
    post "/register", PageController, :signup

    get  "/login", PageController, :login
    post "/login", PageController, :login

    get   "/forgot-password", PageController, :forgot_password
    post  "/forgot-password", PageController, :forgot_password

    get "/logout", PageController, :logout
  end

  scope "/api" do
    pipe_through(:api)

    forward("/", Absinthe.Plug, schema: PhxGraphqlWeb.Schema)
    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: PhxGraphqlWeb.Schema)
  end

  scope "/app", PhxGraphqlWeb do
    pipe_through [:browser, :app]
    
    get "/*path", AppController, :index
  end
end
