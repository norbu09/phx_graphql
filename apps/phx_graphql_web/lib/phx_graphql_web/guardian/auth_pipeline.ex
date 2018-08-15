defmodule PhxGraphqlWeb.Guardian.AuthPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :everything_web,
    module: PhxGraphqlWeb.Guardian,
    error_handler: PhxGraphqlWeb.Guardian.AuthErrorHandler

  plug(Guardian.Plug.VerifySession, claims: @claims)
  plug(Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
