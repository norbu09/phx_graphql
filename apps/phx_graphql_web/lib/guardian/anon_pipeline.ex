defmodule PhxGraphqlWeb.Guardian.AnonPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :phx_graphql_web,
                              module: PhxGraphqlWeb.Guardian,
                              error_handler: PhxGraphqlWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer"

end
