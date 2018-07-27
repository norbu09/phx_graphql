defmodule PhxGraphql.User do
  require Logger
  alias PhxGraphql.Users.User

  @db Application.get_env(:couchex, :db)

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

  @spec update(%User{}) :: {:ok, %User{}} | {:error, atom()}
  def update(user) do
    {:ok, user}
  end
  
  #### internal functions

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
end
