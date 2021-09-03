defmodule Partpicker.TCG.RandomCardGenerator do
  @moduledoc """
  Deletes cards from the random_card ets table after a certain amount of time
  """
  use GenServer
  require Logger

  @table_name :partpicker_random_cards
  @endpoint PartpickerWeb.Endpoint
  @expire_timeout_ms 30_000
  alias Partpicker.TCG

  def generate(generator \\ __MODULE__) do
    GenServer.call(generator, :generate)
  end

  def claim(generator \\ __MODULE__, uuid, user) do
    GenServer.call(generator, {:claim, uuid, user})
  end

  @doc false
  def start_link(table_name \\ @table_name, opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, table_name, opts)
  end

  @impl GenServer
  def init(table_name) do
    table = :ets.new(table_name, [:public, :named_table, :set])
    {:ok, %{table: table}}
  end

  @impl GenServer
  def handle_call(:generate, _, state) do
    random_card =
      TCG.random_plate()
      |> TCG.new_virtual_card()

    uuid = Base.encode16(random_card.uuid, case: :upper)
    timer = Process.send_after(self(), {:expire, uuid}, @expire_timeout_ms)
    true = :ets.insert(state.table, {uuid, timer, random_card})
    {:reply, random_card, state}
  end

  def handle_call({:claim, uuid, _user}, _, state) do
    case :ets.lookup(state.table, uuid) do
      [{_uuid, timer, card}] ->
        :ets.delete(state.table, uuid)
        _ = Process.cancel_timer(timer)
        {:reply, {:ok, card}, state}

      [] ->
        {:reply, {:error, :not_found}, state}
    end
  end

  @impl GenServer
  def handle_info({:expire, uuid}, state) do
    :ets.delete(state.table, uuid)
    @endpoint.broadcast!("tcg", "RANDOM_CARD_EXPIRE", %{id: uuid})
    {:noreply, state}
  end
end
