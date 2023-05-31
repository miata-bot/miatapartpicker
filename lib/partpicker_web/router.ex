defmodule PartpickerWeb.Router do
  use PartpickerWeb, :router

  import PartpickerWeb.UserAuth
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

      resources "/builds", BuildController, only: [:index, :show, :create, :update, :delete] do
        post "/banner", BuildController, :banner
      end
    end

    post "/photos/random", PhotoController, :random
    get "/cards/generate_random_offer", CardController, :generate_random_offer
    post "/cards/claim_random_offer", CardController, :claim_random_offer
  end

  scope "/", PartpickerWeb do
    pipe_through [:browser]
    get "/media/:uuid", MediaController, :show
  end
end
