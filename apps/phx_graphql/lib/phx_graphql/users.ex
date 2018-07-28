defmodule PhxGraphql.User do
  require Logger
  alias PhxGraphql.Users.User
  alias PhxGraphql.Users.Token

  @db Application.get_env(:couchex, :db)

  # user functions ###
  @spec validate_password(binary(), binary()) :: {:ok, %User{}} | {:error, atom()}
  def validate_password(user_id, pass) do
    case get_user_with_pw(user_id) do
      {:ok, user} ->
        case Pbkdf2.verify_pass(pass, user["password"]) do
          true -> {:ok, User.new(user)}
          _ -> {:error, :invalid_auth}
        end

      _ ->
        Pbkdf2.no_user_verify()
        {:error, :invalid_auth}
    end
  end
  def validate_password(_) do
    Pbkdf2.no_user_verify()
    {:error, :invalid_credentials}
  end

  @spec validate_token(binary()) :: {:ok, %User{}} | {:error, atom()}
  def validate_token(token) do
    case Couchex.Client.get(@db, %{view: "user/by_token"}, %{
           "key" => token,
           "include_docs" => true
         }) do
      {:ok, [%{"doc" => %{"_id" => _id} = user}]} ->
        {:ok, User.new(user)}

      _ ->
        {:error, :invalid_token}
    end
  end

  @spec create(%{
          required(:username) => binary(),
          required(:password) => binary(),
          optional(any) => any
        }) :: {:ok, %User{}} | {:error, atom()}
  def create(user) do
    create_user(user)
  end

  @spec now() :: integer()
  def now do
    DateTime.to_unix(DateTime.utc_now())
  end

  @spec update(%User{}, %User{}) :: {:ok, %User{}} | {:error, atom()}
  def update(user, update) do
    case user.id == update.id do
      true ->
        case User.update(update) do
          {:ok, _upd} ->
            {:ok, update}
          error ->
          Logger.error("Update failed: #{inspect user} -> #{inspect update}: #{inspect error}")
            {:error, :update_failed}
        end
      false -> {:error, :authentication_error}
    end
  end
  
  @spec pw_update(%User{}, binary(), binary()) :: {:ok, %User{}} | {:error, atom()}
  def pw_update(user, current, new) do
    case validate_password(user.username, current) do
      {:ok, user} ->
        password = Pbkdf2.hash_pwd_salt(new)
        case User.update(user, %{password: password}) do
          {:ok, _upd} -> {:ok, user}
          error -> 
            Logger.error("Update failed: #{inspect error}")
            {:error, :update_failed}
        end
      error -> 
        Logger.error("Password update: #{inspect error}")
        {:error, :authentication_error}
    end
  end 

  # token functions ###

  @spec add_token(%User{}) :: {:ok, [%Token{}, ...]} | {:error, atom()}
  def add_token(user) do
    curr_token = case get_token(user) do
      {:error, :no_token} -> []
      {:ok, token} -> token
    end
    token = curr_token ++ generate_token(20)
    update_token(user, token)
  end

  @spec get_token(%User{}) :: {:ok, [%Token{}, ...]} | {:error, atom()}
  def get_token(user) do
    case get_user_with_pw(user.username) do
      {:ok, user} -> 
        case user["token"] do
          nil -> {:error, :no_token}
          token -> 
            {:ok, Token.new(token)}
        end
      {:error, error} -> {:error, error}
    end
  end

  @spec del_token(%User{}, binary()) :: {:ok, [%Token{}, ...]} | {:error, atom()}
  def del_token(user, token) do
    token_user = case validate_token(token) do
      {:ok, user} -> user
      _ -> PhxGraphql.Users.User.new(%{})
    end
    case user.id == token_user.id do
      true ->
        {:ok, curr_token} = get_token(user)
        new_token = Enum.filter(curr_token, fn(x) -> Map.fetch!(x, :token) != token end)
        update_token(user, new_token)
      error -> 
        Logger.error("Del token failed: #{inspect error}")
        {:error, :authentication_error}
    end
  end
  #### internal functions

  defp update_token(user, token) do
    case User.update(user, %{token: token}) do
      {:ok, _upd} -> {:ok, token}
      error -> 
        Logger.error("Update failed: #{inspect error}")
        {:error, :update_failed}
    end
  end

  defp create_user(user) do
    case user_exists?(user["username"]) do
      true ->
        Logger.debug("User #{user["username"]} exists!")
        {:error, :user_exists}

      false ->
        user1 =
          user
          |> clean_post_data
          |> add_meta("user")
          |> encrypt_password

        Logger.debug("Creating User: #{inspect(user1)}")

        case Couchex.Client.put(@db, user1) do
          {:ok, insert} ->
            u2 = Map.put(user1, "_id", insert["id"])
            {:ok, User.new(u2)}

          error ->
            Logger.error("Error creating user: #{inspect(error)}")
            error
        end
    end
  end

  defp user_exists?(username) do
    case Couchex.Client.get(@db, %{view: "user/by_username"}, %{
           "key" => String.downcase(username)
         }) do
      {:ok, [%{"id" => _id}]} -> true
      _ -> false
    end
  end

  defp get_user_with_pw(username) do
    {:ok, view} =
      Couchex.Client.get(@db, %{view: "user/by_username", key_based: true}, %{
        "include_docs" => true,
        "key" => String.downcase(username)
      })

    Logger.debug("Found a user: #{inspect(view)}")

    case view[username] do
      nil ->
        {:error, :no_user}

      user ->
        {:ok, user}
    end
  end

  defp clean_post_data(data) do
    fields = ["company", "username", "password"]

    Enum.filter(data, fn {x, _y} -> x in fields end)
    |> Map.new()
  end

  defp add_meta(doc, type) do
    meta = %{
      "created" => now(),
      "type" => type
    }

    Map.merge(doc, meta)
  end

  defp encrypt_password(doc) do
    %{
      doc
      | "username" => String.downcase(doc["username"]),
        "password" => Pbkdf2.hash_pwd_salt(doc["password"])
    }
  end

  defp random_str(len) do
    :crypto.strong_rand_bytes(len)
    |> Base.encode64
    |> String.downcase
    |> String.replace(~r/\W/, "a")
  end

  defp generate_token(len) do
    token = random_str(len)
    # TODO: call validate_token(token) to check for collisions
    [%{token: token, created: now()}]
  end

end
