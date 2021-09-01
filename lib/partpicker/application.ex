defmodule Partpicker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :partpicker_lists = :ets.new(:partpicker_lists, [:public, :named_table, :set])

    children = [
      # Start the Ecto repository
      Partpicker.Repo,
      # Start the Telemetry supervisor
      PartpickerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Partpicker.PubSub},
      # Start the RandomCardGenerator
      {Partpicker.TCG.RandomCardGenerator, :partpicker_random_cards},
      # Start the Endpoint (http/https)
      PartpickerWeb.Endpoint
      # Start a worker by calling: Partpicker.Worker.start_link(arg)
      # {Partpicker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Partpicker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PartpickerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
