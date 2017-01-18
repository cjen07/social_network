ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(SocialNetwork.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:wallaby)

 Application.put_env(:wallaby, :base_url, "http://localhost:4001")