defmodule PartpickerWeb.Router do
  use PartpickerWeb, :router

  import PartpickerWeb.UserAuth
  import Phoenix.LiveDashboard.Router
  require Logger

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PartpickerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :check_api_token
  end

  scope "/api", PartpickerWeb do
    pipe_through :api

    resources "/users", UserController, only: [:index, :show, :update, :create] do
      put "/featured_build", UserController, :featured_build

      resources "/builds", BuildController, only: [:index, :show, :create, :update] do
        post "/banner", BuildController, :banner
      end
    end

    post "/photos/random", PhotoController, :random
    get "/cards/generate_random_offer", CardController, :generate_random_offer
    post "/cards/claim_random_offer", CardController, :claim_random_offer
  end

  ## Authentication routes

  scope "/", PartpickerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/users/settings", UserSettingsLive, :edit

    live "/builds", BuildLive.Index, :index
    live "/builds/new", BuildLive.Index, :new
    live "/builds/:id/edit", BuildLive.Index, :edit

    live "/builds/:id", BuildLive.Show, :show
    live "/builds/:id/show/edit", BuildLive.Show, :edit
    live "/builds/:id/show/new_part", BuildLive.Show, :new_part

    live "/builds/:build_id/parts/import", PartLive.Import, :import
    live "/builds/:build_id/parts/import/:import_job", PartLive.ImportStatus, :import_status

    live "/builds/:id/photos/upload", BuildLive.PhotoUpload, :upload

    live "/connectors/new", ConnectorLive.Index, :new
    live "/connectors/:id/edit", ConnectorLive.Index, :edit
    live "/connectors/:id/show/edit", ConnectorLive.Show, :edit

    live "/cards", CardLive.Index, :index
    live "/cards/offers", CardLive.Offers, :offers
    live "/cards/requests", CardLive.Requests, :requests
    live "/cards/:id", CardLive.Show, :show
  end

  scope "/", PartpickerWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]
    live_dashboard "/dashboard", metrics: PartpickerWeb.Telemetry
    live "/api_tokens", APITokenLive.Index, :index
    live "/admin", AdminLive.Index, :index
    live "/admin/:id/edit", AdminLive.Index, :edit
    live "/admin/:id", AdminLive.Show, :show
    live "/admin/:id/show/edit", AdminLive.Show, :edit
  end

  scope "/", PartpickerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/media/:uuid", MediaController, :show
    live "/car/:uid", CarLive.Show, :show

    live "/", PageLive, :index
    get "/oauth/discord", OAuth.DiscordController, :oauth
    live "/connectors", ConnectorLive.Index, :index
    get "/connectors/export", ConnectorExportController, :export
    live "/connectors/:id", ConnectorLive.Show, :show
  end
end
