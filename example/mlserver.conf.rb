settings = MLserver::Settings.new
MLserver.settings = settings

settings.host = "::"
settings.port = 8080
settings.logger = MLserver::DefaultLogger
settings.force_host = false

# SSL
settings.ssl = true
settings.ssl_key = "ssl/server.key"
settings.ssl_cert = "ssl/server.crt"
settings.ssl_additional_certs = ["ssl/chain.crt"]

settings.ssl_port = 4434
settings.ssl_host = "::"

# Client handler
require_relative "app.rb"
settings.handler = Handler
