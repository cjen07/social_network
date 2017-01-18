use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :social_network, SocialNetwork.Endpoint,
  secret_key_base: "LM6UqnxALsin1lsdU1zKqxqFp9cTFNSR1cJ+6A9lbzuBKlkk6Ey6vgT/5FmJstGd"

# Configure your database
config :social_network, SocialNetwork.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "social_network_prod",
  pool_size: 20
