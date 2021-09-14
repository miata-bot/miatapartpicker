defmodule PartpickerWeb.ActiveLink do
  use PartpickerWeb, :surface_component

  prop to, :string, required: true
  prop active, :boolean
  slot default

  def render(assigns) do
    ~F"""
    <LiveRedirect to={@to} class={"px-2", "py-2", "font-medium", active_class(@current_uri, @to)}>
      <#slot />
    </LiveRedirect>
    """
  end

  def active_class(socket, path) do
    IO.inspect(socket, structs: false)
    current_path = Path.join(["/" | socket.path_info])

    if path == current_path do
      "text-white"
    else
      "text-gray-400"
    end
  end

  # def active_link(conn, text, opts) do
  #   class = [opts[:class], active_class(conn, opts[:to])]
  #           |> Enum.filter(& &1)
  #           |> Enum.join(" ")
  #   opts = opts
  #          |> Keyword.put(:class, class)
  #   link(text, opts)
  # end
end
