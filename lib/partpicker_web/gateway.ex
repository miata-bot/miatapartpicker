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
    @endpoint.subscribe("tcg")
    {:ok, state}
  end

  @impl :cowboy_websocket
  def websocket_handle({:text, message}, state) do
    {:reply, {:text, message}, state}
  end

  @impl :cowboy_websocket
  def websocket_info(%Broadcast{event: "CREATE_TRADE_REQUEST", payload: payload}, state) do
    message = {:CREATE_TRADE_REQUEST, payload} |> :erlang.term_to_binary()
    {:reply, {:text, message}, state}
  end

  @impl :cowboy_websocket
  def terminate(reason, _, _state) do
    Logger.debug("Socket exit: #{inspect(reason)}")
  end
end
