# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :social_network,
  ecto_repos: [SocialNetwork.Repo]

# Configures the endpoint
config :social_network, SocialNetwork.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ggYHYJE6bPf5lCE1SwJY4BDmkDX2tUS95GsgR9cjNsCVKxgchgfK4sj9SHVyXgmB",
  render_errors: [view: SocialNetwork.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SocialNetwork.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :bolt_sips, Bolt,
  hostname: 'localhost',
  basic_auth: [username: "neo4j", password: "q"],
  port: 7687,
  pool_size: 5,
  max_overflow: 1

config :arc,
  storage: Arc.Storage.Local

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: SocialNetwork.User,
  repo: SocialNetwork.Repo,
  module: SocialNetwork,
  logged_out_url: "/",
  email_from_name: "Admin",
  email_from_email: "support@social_network.com",
  opts: [:confirmable, :rememberable, :registerable, :authenticatable, :recoverable]

config :coherence, SocialNetwork.Coherence.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: "key-128c9939cdb072c5f1e6198276d000d2",
  domain: "sandboxb4f26e721a0b437fb31fa813247407b3.mailgun.org"
# %% End Coherence Configuration %%
