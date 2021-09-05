defmodule PartpickerWeb.Gateway do
  @moduledoc """
  Gateway for crud changes over WebSockets
  """

  require Logger
  @behaviour :cowboy_websocket
  @endpoint PartpickerWeb.Endpoint
  alias Phoenix.Socket.Broadcast

  @impl :cowboy_websocket
  def init(req, _opts) do
    {:cowboy_websocket, req, %{}, %{idle_timeout: :infinity}}
  end

  @impl :cowboy_websocket
  def websocket_init(state) do
    Logger.info("New Gateway connection")
    @endpoint.subscribe("tcg")
    send(self(), :send_ping)
    {:ok, state}
  end

  @impl :cowboy_websocket
  def websocket_handle({:text, message}, state) do
    {:reply, {:text, message}, state}
  end

  def websocket_handle(:pong, state) do
    Process.send_after(self(), :send_ping, 5000)
    {:ok, state}
  end

  @impl :cowboy_websocket
  def websocket_info(%Broadcast{event: "CREATE_TRADE_REQUEST", payload: payload}, state) do
    {:reply, {:text, Jason.encode!(["CREATE_TRADE_REQUEST", payload])}, state}
  end

  def websocket_info(%Broadcast{event: "RANDOM_CARD_EXPIRE", payload: payload}, state) do
    {:reply, {:text, Jason.encode!(["RANDOM_CARD_EXPIRE", payload])}, state}
  end

  def websocket_info(:send_ping, state) do
    {:reply, :ping, state}
  end

  @impl :cowboy_websocket
  def terminate(reason, _, _state) do
    Logger.debug("Socket exit: #{inspect(reason)}")
  end
end
