defmodule Partpicker.Repo do
  use Ecto.Repo,
    otp_app: :partpicker,
    adapter: Ecto.Adapters.Postgres
end
