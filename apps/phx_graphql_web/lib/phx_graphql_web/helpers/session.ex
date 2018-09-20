defmodule PhxGraphqlWeb.Session do
  alias PhxGraphql.User
  alias PhxGraphqlWeb.Guardian

  def authenticate(%{"username" => username, "password" => password}) do
    User.validate_password(String.downcase(username), password)
  end

  def authorize(token) do
    User.validate_token(token)
  end

  def parse_token(token) do
    case Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:ok, user}

      _ ->
        case authorize(token) do
          {:ok, user} -> {:ok, user}
          _ -> {:error, :not_found}
        end
    end
  end
end
