module MLserver
  def self.version
    "1.0.3"
  end
end

require "socket"
require "rbtext"
require "rbtext/string_methods"
require "openssl"
require_relative "MLserver/request.rb"
require_relative "MLserver/request_parser.rb"
require_relative "MLserver/response.rb"
require_relative "MLserver/server.rb"
require_relative "MLserver/client_handler.rb"
require_relative "MLserver/logger.rb"
require_relative "MLserver/error_response.rb"
require_relative "MLserver/redirect_response.rb"
require_relative "MLserver/settings.rb"
