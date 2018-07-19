defmodule PhxGraphqlWeb.Guardian do
  use Guardian, otp_app: :makemysale

  alias PhxGraphql.User

  # TODO this needs an actual implementation!
  def subject_for_token(%{"_id" => user_id}, _claims), do: {:ok, "User:#{user_id}"}
  def subject_for_token(thing, _claims), do: {:error, "Unknown resource type1: #{inspect thing}"}

  def resource_from_claims("User:" <> id), do: User.get_user_by_id(id)
  def resource_from_claims(%{"sub" => "User:" <> id}), do: User.get_user_by_id(id)
  def resource_from_claims(thing), do: {:error, "Unknown resource type2: #{inspect thing}"}
 
end
