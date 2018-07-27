defmodule PhxGraphqlWeb.Session do
  alias PhxGraphql.User

  def authenticate(%{"username" => username, "password" => password}) do
    User.validate_password(String.downcase(username), password)
  end

  def authorize(token) do
    User.validate_token(token)
  end
end
