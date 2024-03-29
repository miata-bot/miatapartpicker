defmodule Partpicker.MixProject do
  use Mix.Project

  @app :partpicker

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.7",
      commit: commit(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :phoenix_swagger] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      releases: [{@app, release()}],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def compilers(:dev) do
  end

  def compilers(_) do
    [:phoenix] ++ Mix.compilers()
  end

  defp commit do
    System.get_env("COMMIT") ||
      System.cmd("git", ~w"rev-parse --verify HEAD", [])
      |> elem(0)
      |> String.trim()
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Partpicker.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
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
      {:base62, "~> 1.2"},
      {:bcrypt_elixir, "~> 2.0"},
      {:cowlib, "~> 2.10", override: true},
      {:ecto_sql, "~> 3.4"},
      {:ecto_sqlite3, "~> 0.7.2"},
      {:floki, ">= 0.27.0", only: :test},
      {:gettext, "~> 0.11"},
      {:gun, "~> 1.3", override: true},
      {:jason, "~> 1.0"},
      {:nimble_csv, "~> 1.1"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix, "~> 1.6"},
      {:plug_cowboy, "~> 2.1"},
      {:postgrex, ">= 0.0.0"},
      {:ring_logger, "~> 0.8"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 1.0"},
      {:tesla, "~> 1.4"},
      {:timex, "~> 3.6"},
      {:phoenix_swagger, "~> 0.8"},
      {:ex_json_schema, "~> 0.0"},
      {:mogrify, "~> 0.9.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp release do
    [
      overwrite: true,
      include_executables_for: [:unix],
      strip_beams: [keep: ["Docs"]],
      applications: [runtime_tools: :permanent],
      steps: [:assemble],
      cookie: "aHR0cHM6Ly9kaXNjb3JkLmdnL25tOENFVDJNc1A="
    ]
  end
end
