defmodule Partpicker.Builds.FeaturedBuild do
  use Ecto.Schema

  schema "featured_builds" do
    belongs_to :build, Partpicker.Builds.Build
    belongs_to :user, Partpicker.Accounts.User
    timestamps()
  end
end
