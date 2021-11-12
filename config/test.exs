import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crypto_watch, CryptoWatchWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "eSO6C02QVG9RQHS9fN+yg3MA4h8S06W4e1P0NT5HWq0UhQgqE0ur84cDpPQyqd+a",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
