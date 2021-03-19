defmodule PartpickerWeb.UserView do
  use PartpickerWeb, :view

  def render("show.json", %{user: %{featured_build: %{build: featured_build}} = user}) do
    %{
      discord_user_id: user.discord_user_id,
      instagram_handle: user.instagram_handle,
      prefered_unit: user.prefered_unit,
      featured_build: render_one(featured_build, PartpickerWeb.BuildView, "show.json"),
      builds: render_many(user.builds, PartpickerWeb.BuildView, "show.json")
    }
  end

  def render("show.json", %{user: %{featured_build: nil} = user}) do
    %{
      discord_user_id: user.discord_user_id,
      instagram_handle: user.instagram_handle,
      prefered_unit: user.prefered_unit,
      featured_build: nil,
      builds: render_many(user.builds, PartpickerWeb.BuildView, "show.json")
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
