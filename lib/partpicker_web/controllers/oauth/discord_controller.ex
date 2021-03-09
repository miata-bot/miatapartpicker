defmodule PartpickerWeb.OAuth.DiscordController do
  use PartpickerWeb, :controller
  alias PartpickerWeb.OAuth.Discord, as: OAuth
  require Logger

  def logout(conn, _) do
    PartpickerWeb.UserAuth.log_out_user(conn)
  end

  def oauth(conn, %{"code" => code, "state" => _return_to} = params) do
    Logger.info("Discord Oauth: #{inspect(params)}")
    client = OAuth.exchange_code(code)

    with {:ok, me} <- OAuth.me(client),
         _ <- Logger.warn("oauth result: #{inspect(me)}") do
      IO.inspect(me, label: "ME")

      case Partpicker.Accounts.get_user_by_discord_id(me["id"]) do
        nil ->
          {:ok, user} = Partpicker.Accounts.register_user_with_oauth_discord(me)
          Logger.info("Created user from discord: #{inspect(user)}")

          conn
          |> put_session(:user_return_to, Routes.page_path(conn, :index))
          |> PartpickerWeb.UserAuth.log_in_user(user, me)

        user ->
          Logger.info("Logged in #{inspect(user)}")
          {:ok, user} = Partpicker.Accounts.update_discord_oauth_info(user, me)

          conn
          # |> put_session(:user_return_to, return_to)
          |> PartpickerWeb.UserAuth.log_in_user(user, me)
      end
    end
  end

  def oauth(conn, %{"error" => error, "error_description" => reason}) do
    conn
    |> put_flash(:error, "#{error} #{reason}")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
