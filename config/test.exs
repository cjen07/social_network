use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :social_network, SocialNetwork.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :social_network, SocialNetwork.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "social_network_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :wallaby, screenshot_on_failure: true

config :social_network, :sql_sandbox, true
