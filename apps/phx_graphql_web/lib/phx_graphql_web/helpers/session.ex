defmodule PhxGraphqlWeb.Session do
  alias PhxGraphql.User

  def authenticate(%{"email" => email, "password" => password}) do
    User.validate_password(String.downcase(email), password)
  end

end
