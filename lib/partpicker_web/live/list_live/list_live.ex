defmodule PartpickerWeb.ListLive do
  use PartpickerWeb, :live_view

  alias Partpicker.{
    Lists,
    List,
    List.Part
  }

  @impl true
  def mount(%{"tag" => tag}, _session, socket) do
    case find_list(tag) do
      %List{} = list ->
        {:ok,
         socket
         |> assign(:list, list)
         |> assign(:parts, list.parts)
         |> assign(:changeset, Lists.change_list(list))}

      %Ecto.Changeset{} = changeset ->
        {:ok,
         socket
         |> assign(:list, Ecto.Changeset.apply_changes(changeset))
         |> assign(:parts, default_parts())
         |> assign(:changeset, changeset)
         |> cache()}

      nil ->
        {:ok,
         socket
         |> assign(:list, %List{})
         |> assign(:parts, default_parts())
         |> assign(:changeset, Lists.change_list(%List{}))
         |> cache()}
    end
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:list, %List{})
     |> assign(:parts, default_parts())
     |> assign(:changeset, Lists.change_list(%List{}))
     |> cache()}
  end

  def default_parts,
    do: [
      %Part{name: "ECU"},
      %Part{name: "Injectors"},
      %Part{name: "Wideband"},
      %Part{name: "Wheels"},
      %Part{name: "Tires"}
    ]

  def find_list(tag) do
    Lists.find_list_by_tag(tag) || Lists.find_cached_list(tag)
  end

  def cache(socket) do
    Lists.cache_list(socket.assigns.changeset)
    socket
  end
end
