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

    live "/parts/import", PartLive.Import, :import
    live "/parts/import/:import_job", PartLive.ImportStatus, :import_status

    live_dashboard "/dashboard", metrics: PartpickerWeb.Telemetry
  end

  scope "/", PartpickerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
