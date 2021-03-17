defmodule PartpickerWeb.UserView do
  use PartpickerWeb, :view

  def render("show.json", %{user: user}) do
    %{
      discord_user_id: user.discord_user_id,
      instagram_handle: user.instagram_handle,
      prefered_unit: user.prefered_unit
    }
  end

  def render("error.json", %{error: changeset}) do
    %{
      status: "failure",
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end
end
