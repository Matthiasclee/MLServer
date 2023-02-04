module MLserver
  class Settings
    def initialize(host: "0.0.0.0", port: "5555", handler:, logger:, force_host: false)
      @host = host
      @port = port.to_i
      @handler = handler
      @logger = logger
      @force_host = force_host
    end

    attr_accessor :host, :port, :handler, :logger, :force_host
  end
end