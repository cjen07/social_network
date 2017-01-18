defmodule SocialNetwork.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias SocialNetwork.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import SocialNetwork.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SocialNetwork.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SocialNetwork.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(SocialNetwork.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end