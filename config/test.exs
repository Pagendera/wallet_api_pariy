import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :wallet_api_pariy, WalletApiPariy.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "wallet_api_pariy_test#{System.get_env("MIX_TEST_PARTITION")}",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wallet_api_pariy, WalletApiPariyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dn5M6/JNBlLBZXfHlZFSGQhoIaG7E7WDA0VL/UedyDWtt/FWOys8W14Zb/mk7jR2",
  server: false

# In test we don't send emails.
config :wallet_api_pariy, WalletApiPariy.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
