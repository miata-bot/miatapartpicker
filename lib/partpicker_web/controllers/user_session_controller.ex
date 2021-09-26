defmodule PartpickerWeb.UserSessionController do
  use PartpickerWeb, :controller

  alias PartpickerWeb.UserAuth

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
