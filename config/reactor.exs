use Mix.Config
import_config "prod.exs"

# # Configure your database
# config :partpicker, Partpicker.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "partpicker_dev",
#   hostname: "localhost",
#   show_sensitive_data_on_connection_error: true,
#   pool_size: 10

# # For development, we disable any cache and enable
# # debugging and code reloading.
# #
# # The watchers configuration can be used to run external
# # watchers to your application. For example, we use it
# # with webpack to recompile .js and .css sources.
# config :partpicker, PartpickerWeb.Endpoint,
#   http: [port: 4000],
#   server: false,
#   debug_errors: true,
#   code_reloader: true,
#   check_origin: false,
#   live_reload: [
#     patterns: [
#       ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
#       ~r"priv/gettext/.*(po)$",
#       ~r"lib/partpicker_web/(live|views)/.*(ex)$",
#       ~r"lib/partpicker_web/templates/.*(eex)$"
#     ],
#   watchers: [
#     node: [
#       "node_modules/webpack/bin/webpack.js",
#       "--mode",
#       "development",
#       "--watch-stdin",
#       cd: Path.expand("../assets", __DIR__)
#     ]
#   ]

# # Do not include metadata nor timestamps in development logs
# config :logger, :console, format: "[$level] $message\n"

# # Set a higher stacktrace during development. Avoid configuring such
# # in production as building large stacktraces may be expensive.
# config :phoenix, :stacktrace_depth, 20

# # Initialize plugs at runtime for faster development compilation
# config :phoenix, :plug_init_mode, :runtime
