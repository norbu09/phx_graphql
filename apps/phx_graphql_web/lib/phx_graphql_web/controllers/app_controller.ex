defmodule PhxGraphqlWeb.AppController do
  use PhxGraphqlWeb, :controller
  require Logger
  alias PhxGraphqlWeb.Guardian
  alias PhxGraphql.User

  def index(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    claims = Guardian.Plug.current_claims(conn)
    seed = case resolve_claim(claims) do
      {:ok, user} -> 
        put_session(conn, :user, user)
        %{"user" => user}
      error -> error
    end
    initial_state = %{"phx_graphql" => Map.put(seed, "jwt", token)}

    conn
    |> render("index.html", [props: initial_state])
  end
  
  def unauthenticated(conn, _params) do
    redirect(conn, to: "/")
  end

  defp resolve_claim(%{"sub" => user}) do
    case String.split(user, ":") do
      ["User", id] -> User.get_user_by_id(id)
      _ -> {:error, :no_user_id}
    end
  end
  
end
