defmodule PartpickerWeb.UserSessionController do
  use PartpickerWeb, :controller

  alias PartpickerWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
