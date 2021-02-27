defmodule PartpickerWeb.ProductLive do
  use PartpickerWeb, :live_view

  alias Partpicker.{
    Lists,
    List,
    List.Part
  }

  @impl true
  def mount(%{"list_tag" => list_tag, "tag" => tag}, _session, socket) do
    results = Lists.selection_for_tag(tag)

    {:ok,
     socket
     |> assign(:list_tag, list_tag)
     |> assign(:tag, tag)
     |> assign(:results, results)}
  end
end
