defmodule PartpickerWeb.UserSettingsController do
  use PartpickerWeb, :controller

  alias Partpicker.Accounts

  def edit(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> assign(:settings_changeset, Accounts.change_settings(user))
    |> render("edit.html")
  end

  def update(conn, %{"action" => "update_settings", "user" => settings}) do
    user = conn.assigns.current_user

    case Accounts.update_settings(user, settings) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Settings updated")
        |> render("edit.html", settings_changeset: Accounts.change_settings(user))

      {:error, changeset} ->
        render(conn, "edit.html", settings_changeset: changeset)
    end
  end
end
