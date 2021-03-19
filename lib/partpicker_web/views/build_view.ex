defmodule PartpickerWeb.BuildView do
  use PartpickerWeb, :view

  def render("index.json", %{builds: builds}) do
    render_many(builds, PartpickerWeb.BuildView, "show.json")
  end

  def render("show.json", %{build: build}) do
    %{
      uid: build.uid,
      color: build.color,
      make: build.make,
      model: build.model,
      year: build.year,
      wheels: build.wheels,
      tires: build.tires,
      vin: build.vin,
      description: build.description,
      mileage: build.mileage,
      photos: render_many(build.photos, PartpickerWeb.PhotoView, "show.json"),
      banner_photo_id: build.banner_photo_id
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
