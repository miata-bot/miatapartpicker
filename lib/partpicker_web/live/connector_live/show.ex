defmodule PartpickerWeb.ConnectorLive.Show do
  use PartpickerWeb, :live_view

  defmodule MyWorker do
    @moduledoc """
    Consider you have a process, off doing some work. We will call it `MyWorker`.
    This worker will do one simple task, increment a count.

    You start a worker with:

        iex> {:ok, worker} = MyWorker.start_link(0)
        {:ok, #PID<0.185.0>}

    Now that worker will start incrementing the count at random intervals. We can
    check the state of the worker using the `:sys` module:

        iex> :sys.get_state(worker)
        %{caller: nil, value: 34}

    Now we want the worker to keep doing it's work; we may also want the current process (not the worker)
    to be blocked until a certain amount of work is done. The function `block_until_eq/2` will
    block the current process, `(self())` until the work count reaches the inputted value.

      iex> MyWorker.block_until_eq(worker, 50)
      # process will be blocked until the work is up..
      {:ok, 50}

    While the calling processes is blocked, the Worker is still processing
    """
    use GenServer

    def start_link(initial_value \\ 0), do: GenServer.start_link(__MODULE__, initial_value)

    def block_until_eq(worker, input, timeout \\ 5_000) do
      GenServer.call(worker, {:block_until_eq, input}, timeout)
    end

    @impl GenServer
    def init(initial_value) do
      send self(), :work
      {:ok, %{value: initial_value, caller: nil}}
    end

    @impl GenServer
    def handle_info(:work, state) do
      state = do_work(state)
      send self(), :work
      {:noreply, state}
    end

    @impl GenServer
    def handle_call({:block_until_eq, input}, caller, state) do
      {:noreply, %{state | caller: {caller, input}}}
    end

    # if the work has increased `value` such that the value is now greater than block,
    # we return the `handle_call` to the calling process
    def do_work(%{value: value, caller: {caller, block}} = state) when value > block do
      _ = GenServer.reply(caller, {:ok, value})
      %{state | value: 0, caller: nil}
    end

    # otherwise, continue working
    def do_work(%{value: value} = state) do
      # pretend work going on here
      Process.sleep(System.unique_integer([:positive]))
      new_value = value + 1
      %{state | value: new_value}
    end
  end

  alias Partpicker.Library

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:user, user)}
    end
  end

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:user, nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    connector = Library.get_connector!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:connector, connector)
     |> assign_meta(connector)}
  end

  defp page_title(:show), do: "Show Connector"
  defp page_title(:edit), do: "Edit Connector"

  defp assign_meta(socket, connector) do
    socket
    |> assign(:meta_description, connector.description || "")
    |> assign(:meta_image, Routes.static_path(socket, "/images/connectors/#{connector.name}.png"))
    |> assign(:meta_image_type, "image/png")
  end
end
