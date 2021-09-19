# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :partpicker,
  ecto_repos: [Partpicker.Repo]

dispatch_config = [
  _: [
    {"/api/gateway", PartpickerWeb.Gateway, []},
    {:_, Phoenix.Endpoint.Cowboy2Handler, {PartpickerWeb.Endpoint, []}}
  ]
]

# Configures the endpoint
config :partpicker, PartpickerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "x3wRvqMtQDBXFi7gPktFmxJY85ert441I1cL/lMIrJTsrvLhWXWRmxB1iH6fPJMD",
  render_errors: [view: PartpickerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Partpicker.PubSub,
  live_view: [signing_salt: "0f1mUI2o"],
  http: [dispatch: dispatch_config]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

if discord_client_id = System.get_env("DISCORD_CLIENT_ID") do
  config :partpicker, PartpickerWeb.OAuth.Discord, client_id: discord_client_id
end

if discord_client_secret = System.get_env("DISCORD_CLIENT_SECRET") do
  config :partpicker, PartpickerWeb.OAuth.Discord, client_secret: discord_client_secret
end

config :partpicker, PartpickerWeb.OAuth.Discord, url: "http://localhost:4000/oauth/discord"
config :partpicker, TrackerGG, api_token: System.get_env("TRACKER_GG_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
