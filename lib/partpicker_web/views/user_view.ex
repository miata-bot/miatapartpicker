defmodule PartpickerWeb.UserView do
  use PartpickerWeb, :view

  def render("show.json", %{user: user}) do
    %{
      discord_user_id: user.discord_user_id,
      instagram_handle: user.instagram_handle
    }
  end
end
