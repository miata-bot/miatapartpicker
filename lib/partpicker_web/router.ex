defmodule PartpickerWeb.Router do
  use PartpickerWeb, :router

  import PartpickerWeb.UserAuth
  import Phoenix.LiveDashboard.Router

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
    get "/builds/:discord_user_id/", BuildController, :index
    get "/builds/:discord_user_id/:uid", BuildController, :show
    post "/builds/:discord_user_id/:uid", BuildController, :update
    post "/users/:discord_user_id/", UserController, :update
  end

  scope "/", PartpickerWeb do
    pipe_through :browser

    live "/", PageLive, :index
    get "/oauth/discord", OAuth.DiscordController, :oauth
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

    live "/builds/:id/photos/upload", BuildLive.PhotoUpload, :upload

    live "/parts/import", PartLive.Import, :import
    live "/parts/import/:import_job", PartLive.ImportStatus, :import_status
  end

  scope "/", PartpickerWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]
    live_dashboard "/dashboard", metrics: PartpickerWeb.Telemetry
    live "/api_tokens", APITokenLive.Index, :index
  end

  scope "/", PartpickerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
    get "/media/:uuid", MediaController, :show
    live "/car/:uid", CarLive.Show, :show
  end
end
