module MLserver
  def self.version
    "0.4.0"
  end
end

require "socket"
require_relative "MLserver/request.rb"
require_relative "MLserver/request_parser.rb"
require_relative "MLserver/response.rb"
require_relative "MLserver/server.rb"
require_relative "MLserver/client_handler.rb"
