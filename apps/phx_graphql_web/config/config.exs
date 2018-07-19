# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phx_graphql_web, namespace: PhxGraphqlWeb

# Configures the endpoint
config :phx_graphql_web, PhxGraphqlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TfrmM49+ZpBIctCwEGJN6mZvzi4vF55Blw4XB/EpYIyQ0JAIFGRUDvOpiKSPT09J",
  render_errors: [view: PhxGraphqlWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhxGraphqlWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phx_graphql_web, :generators, context_app: :phx_graphql

config :phx_graphql_web, PhxGraphqlWeb.Guardian,
  issuer: "PhxGraphql",
  allowed_algos: ["HS512", "HS384"],
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "Jr2DmPXTx5xxO/6Rd0/1HAvmw1eqEPGf29h68eCCIp45Unosm5DkxU1osgSRUiO+"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
