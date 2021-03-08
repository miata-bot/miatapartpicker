defmodule PartpickerWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `PartpickerWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, PartpickerWeb.BuildLive.FormComponent,
        id: @build.id || :new,
        action: @live_action,
        build: @build,
        return_to: Routes.build_index_path(@socket, :index) %>
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(_, PartpickerWeb.ModalComponent, modal_opts)
  end
end