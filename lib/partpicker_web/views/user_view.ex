defmodule PartpickerWeb.UserView do
  use PartpickerWeb, :view

  def render("index.json", %{users: users}) do
    render_many(users, __MODULE__, "show.json")
  end

  def render("show.json", %{user: user}) do
    %{
      discord_user_id: user.discord_user_id,
      instagram_handle: user.instagram_handle,
      prefered_unit: user.prefered_unit,
      preferred_timezone: user.preferred_timezone,
      hand_size: user.hand_size,
      foot_size: user.foot_size,
      steam_id: user.steam_id,
      featured_build: user.featured_build.build.uid,
      builds: user.builds
    }
  end

  def render("error.json", %{error: %Ecto.Changeset{} = changeset}) do
    %{
      status: "failure",
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  def render("error.json", %{error: error}) do
    %{
      status: "failure",
      errors: [error]
    }
  end
end
