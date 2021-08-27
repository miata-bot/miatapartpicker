defmodule PartpickerWeb.Router do
  use PartpickerWeb, :router

  import PartpickerWeb.UserAuth
  import Phoenix.LiveDashboard.Router
  require Logger

  def log_ip(conn, _) do
    Logger.info("Client ip: #{inspect(conn)}")
    conn
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PartpickerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :log_ip
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
  end

  ## Authentication routes

  scope "/", PartpickerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", PartpickerWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

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
    live "/cards/trades", CardLive.Trades, :trades
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
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
    get "/media/:uuid", MediaController, :show
    live "/car/:uid", CarLive.Show, :show

    live "/", PageLive, :index
    get "/oauth/discord", OAuth.DiscordController, :oauth
    live "/connectors", ConnectorLive.Index, :index
    get "/connectors/export", ConnectorExportController, :export
    live "/connectors/:id", ConnectorLive.Show, :show
  end
end
