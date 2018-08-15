defmodule PhxGraphqlWeb.Guardian do
  use Guardian, otp_app: :phx_graphql_web
  alias PhxGraphql.User
  alias PhxGraphql.Types.User, as: UserType

  # TODO this needs an actual implementation!
  def subject_for_token(%{"_id" => user_id}, _claims), do: {:ok, "User:#{user_id}"}
  def subject_for_token(%UserType{id: user_id}, _claims), do: {:ok, "User:#{user_id}"}
  def subject_for_token(thing, _claims), do: {:error, "Unknown resource type1: #{inspect(thing)}"}

  def resource_from_claims("User:" <> id), do: get_user(id)
  def resource_from_claims(%{"sub" => "User:" <> id}), do: get_user(id)
  def resource_from_claims(thing), do: {:error, "Unknown resource type2: #{inspect(thing)}"}

  defp get_user(id) do
    case User.get_user(id) do
      {:ok, user} ->
        {:ok, user}

      _ ->
        {:error, :not_found}
    end
  end
end
