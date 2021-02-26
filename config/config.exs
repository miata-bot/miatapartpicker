# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :partpicker,
  ecto_repos: [Partpicker.Repo]

# Configures the endpoint
config :partpicker, PartpickerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "x3wRvqMtQDBXFi7gPktFmxJY85ert441I1cL/lMIrJTsrvLhWXWRmxB1iH6fPJMD",
  render_errors: [view: PartpickerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Partpicker.PubSub,
  live_view: [signing_salt: "0f1mUI2o"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
