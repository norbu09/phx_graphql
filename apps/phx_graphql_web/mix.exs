defmodule PhxGraphqlWeb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phx_graphql_web,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PhxGraphqlWeb.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :absinthe_plug,
        :absinthe_phoenix,
        :comeonin,
        :pbkdf2_elixir,
        :guardian
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 2.6"},

      # API
      {:absinthe_plug, ">= 1.3.0"},
      {:absinthe_phoenix, ">= 1.4.0"},
      {:phx_graphql, in_umbrella: true},

      # Auth
      {:comeonin, ">= 3.0.1"},
      {:pbkdf2_elixir, ">= 0.12.0"},
      {:guardian, ">= 1.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    []
  end
end
