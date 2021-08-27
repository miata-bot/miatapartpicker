defmodule Partpicker.TCG.AlphaSeed do
  alias Partpicker.Repo
  alias Partpicker.{TCG, TCG.PrintingPlate}

  alias Partpicker.Accounts

  @files ["cone-tcg.png", "haz-tcg.png", "john-tcg.png", "threedia-tcg.png"]

  def seed do
    plates =
      for file <- @files do
        %PrintingPlate{filename: file} |> Repo.insert!()
      end

    for user <- Accounts.list_users() do
      for plate <- plates do
        TCG.print_virtual(plate, user)
      end
    end
  end

  def cleanup do
    for tr <- Partpicker.Repo.all(Partpicker.TCG.TradeRequest), do: Partpicker.Repo.delete!(tr)
    for pp <- Partpicker.Repo.all(Partpicker.TCG.PrintingPlate), do: Partpicker.Repo.delete!(pp)
  end
end
