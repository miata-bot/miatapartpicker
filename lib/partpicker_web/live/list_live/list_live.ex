defmodule PartpickerWeb.ListLive do
  use PartpickerWeb, :live_view

  alias Partpicker.{
    Lists,
    List,
    List.Part
  }

  @impl true
  def mount(%{"tag" => tag} = params, _session, socket) do
    case find_list(tag) do
      %List{} = list ->
        {:ok,
         socket
         |> assign(:list, list)
         |> assign(:changeset, Lists.change_list(list))
         |> apply_selection(params)}

      %Ecto.Changeset{} = changeset ->
        {:ok,
         socket
         |> assign(:list, Ecto.Changeset.apply_changes(changeset))
         |> assign(:changeset, changeset)
         |> cache()
         |> apply_selection(params)}

      nil ->
        {:ok,
         socket
         |> assign(:list, %List{
           parts: [%Part{name: "ECU"}]
         })
         |> assign(:changeset, Lists.change_list(%List{parts: [%Part{name: "ECU"}]}))
         |> cache()
         |> apply_selection(params)}
    end
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:list, %List{parts: [%Part{name: "ECU"}]})
     |> assign(:changeset, Lists.change_list(%List{parts: [%Part{name: "ECU"}]}))
     |> cache()}
  end

  def find_list(tag) do
    Lists.find_list_by_tag(tag) || Lists.find_cached_list(tag)
  end

  def cache(socket) do
    Lists.cache_list(socket.assigns.changeset)
    socket
  end

  def apply_selection(socket, %{"product_tag" => _product_tag, "selection_id" => _selection_id}) do
    # Lists.change_list(socket.assigns.changeset, %{"parts"})
    socket
  end

  def apply_selection(socket, %{}) do
    socket
  end
end
