defmodule PhxGraphqlWeb.ProfileResolver do
  require Logger
  alias PhxGraphql.User
  alias PhxGraphql.Types.User, as: UserType

  def get_profile(_root, %{id: _id}, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def get_profile(_root, _args, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def get_profile(_root, _args, _context) do
    {:error, "Not Authorized"}
  end

  def upd_profile(_root, %{profile: update}, %{context: %{current_user: user}}) do
    case UserType.new(update) do
      %UserType{} = upd ->
        User.update(user, upd)

      err ->
        Logger.error("Update: #{inspect(err)}")
        {:error, "Input data validation failed"}
    end
  end

  def upd_profile(_root, _args, _context) do
    Logger.error("Update: not authenticated")
    {:error, "Not Authorized"}
  end

  def upd_passwd(_root, %{current_password: curr_pass, new_password: new_pass}, %{ context: %{current_user: user} }) do
    User.pw_update(user, curr_pass, new_pass)
  end

  def upd_passwd(_root, _args, _context) do
    Logger.error("Update: not authenticated")
    {:error, "Not Authorized"}
  end

  def get_token(_root, _args, %{context: %{current_user: user}}) do
    User.get_token(user)
  end

  def get_token(_root, _args, _context) do
    Logger.error("Token: not authenticated")
    {:error, "Not Authorized"}
  end

  def add_token(_root, _args, %{context: %{current_user: user}}) do
    User.add_token(user)
  end

  def add_token(_root, _args, _context) do
    Logger.error("Token: not authenticated")
    {:error, "Not Authorized"}
  end

  def del_token(_root, %{token: token}, %{context: %{current_user: user}}) do
    User.del_token(user, token)
  end

  def del_token(_root, _args, _context) do
    Logger.error("Token: not authenticated")
    {:error, "Not Authorized"}
  end
end
