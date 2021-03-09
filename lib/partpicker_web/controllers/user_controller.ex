defmodule PartpickerWeb.UserController do
  use PartpickerWeb, :controller

  def update(conn, %{"discord_user_id" => discord_user_id, "user" => user_params}) do
    user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)

    case Partpicker.Accounts.api_change_user(user, user_params) do
      {:ok, user} ->
        render(conn, PartpickerWeb.UserView, "show.json", %{user: user})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("error.json", %{error: changeset})
    end
  end
end
