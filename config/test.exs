import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :green, GreenWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "2P+ROWI6evEFZyrOb/YlZMI+sMauD31gBN4f7GDzpbo9IXBfmU6qU8W0TjXxXarp",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
