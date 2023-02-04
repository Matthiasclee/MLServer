module MLserver
  class Settings
    def initialize(host: "0.0.0.0", port: "5555", handler:, logger:)
      @host = host
      @port = port.to_i
      @handler = handler
      @logger = logger
    end

    attr_accessor :host, :port, :handler, :logger
  end
end
