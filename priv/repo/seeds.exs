require Logger

alias Partpicker.{
        Repo,
        Accounts
      },
      warn: false

{:ok, _user} = Accounts.register_user_with_oauth_discord(%{email: "konnorrigby@gmail.com"})
