defmodule PartpickerWeb.APITokenLive.Index do
  use PartpickerWeb, :live_view

  @impl true
  def mount(_, _session, socket) do
    {:ok,
     socket
     |> assign(:token, nil)
     |> assign(:api_tokens, Partpicker.Repo.all(Partpicker.Accounts.APIToken))}
  end

  @impl true
  def handle_event("generate", _, socket) do
    {token, data} = Partpicker.Accounts.APIToken.build_api_token()
    _ = Partpicker.Repo.insert!(data)

    {:noreply,
     socket
     |> assign(:token, token)}
  end
end
