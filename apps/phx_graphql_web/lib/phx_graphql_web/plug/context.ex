defmodule PhxGraphqlWeb.Context do
  @behaviour Plug

  import Plug.Conn
  alias PhxGraphqlWeb.Session
  alias PhxGraphqlWeb.Guardian
  alias PhxGraphql.Types.User

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), map) :: Plug.Conn.t() | no_return
  def call(conn, _config) do
    context =
      case Guardian.Plug.current_resource(conn) do
        %User{} = user ->
          %{current_user: user}

        _ ->
          build_context(conn)
      end

    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  @spec build_context(Plug.Conn.t()) :: map()
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- Session.parse_token(String.trim(token)) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end
end
