defmodule PhxGraphql.User do
  require Logger

  @db Application.get_env(:couchex, :db)

  def validate_password(user_id, pass) do
    case get_user_with_pw(user_id) do
      {:ok, user} ->
        case Pbkdf2.verify_pass(pass, user["password"]) do
          true -> {:ok, user}
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

  def create(user) do
    create_user(user)
  end

  def get_user() do
    {:error, :no_user}
  end

  def get_user(email) do
    case get_user_with_pw(email) do
      {:ok, user} ->
        {:ok, Map.delete(user, "password")}

      error ->
        error
    end
  end

  #### internal functions

  def now do
    DateTime.to_unix(DateTime.utc_now())
  end

  defp create_user(user) do
    case user_exists?(user["email"]) do
      true ->
        Logger.debug("User #{user["email"]} exists!")
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
            u3 = Map.delete(u2, "password")
            {:ok, u3}

          error ->
            Logger.error("Error creating user: #{inspect error}")
            error
        end
    end
  end

  defp user_exists?(email) do
    case Couchex.Client.get(@db, %{view: "user/by_email"}, %{"key" => String.downcase(email)}) do
      {:ok, [%{"id" => _id}]} -> true
      _ -> false
    end
  end

  defp get_user_with_pw(email) do
    {:ok, view} =
      Couchex.Client.get(@db, %{view: "user/by_email", key_based: true}, %{
        "include_docs" => true,
        "key" => String.downcase(email)
      })

    Logger.debug("Found a user: #{inspect(view)}")

    case view[email] do
      nil ->
        {:error, :no_user}

      user ->
        {:ok, user}
    end
  end

  defp clean_post_data(data) do
    fields = ["company", "email", "password"]

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
      | "email" => String.downcase(doc["email"]),
        "password" => Pbkdf2.hash_pwd_salt(doc["password"])
    }
  end
end
