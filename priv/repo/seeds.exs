require Logger

alias Partpicker.{
  Repo,
  Accounts,
  List,
  List.Part,
  List.Selection
}

{:ok, user} = Accounts.register_user_with_oauth_discord(%{email: "konnorrigby@gmail.com"})

selection =
  %Selection{}
  |> Selection.changeset(%{
    title: "DIY built Megasquirt version 3",
    base: 420.69,
    promo: "",
    shipping: 69.0,
    tax: 0.7,
    where: "https://urmom.gay",
    tags: ["ECU"]
  })
  |> Repo.insert!()

list =
  %List{user_id: user.id}
  |> List.changeset(%{})
  |> Repo.insert!()

part =
  %Part{list_id: list.id, selection_id: selection.id}
  |> Part.changeset(%{name: "ECU"})
  |> Repo.insert!()

Logger.info("Created list #{inspect(list)}")
