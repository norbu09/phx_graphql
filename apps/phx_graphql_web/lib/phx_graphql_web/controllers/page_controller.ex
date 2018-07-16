defmodule PhxGraphqlWeb.PageController do
  use PhxGraphqlWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
