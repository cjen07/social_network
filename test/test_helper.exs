ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(SocialNetwork.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:wallaby)

