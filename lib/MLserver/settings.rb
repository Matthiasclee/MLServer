module MLserver
  @@settings = nil

  class Settings
    def initialize(host: "0.0.0.0", port: "5555")
      @host = host
      @port = port.to_i
      @handler = nil
      @logger = nil
      @force_host = nil
      @ssl = nil
      @ssl_key = nil
      @ssl_cert = nil
      @ssl_additional_certs = []
      @ssl_host = nil
      @ssl_port  = nil
      @trim_urls = false
      @max_connections = 1000
    end

    attr_accessor :host, :port, :handler, :logger, :force_host, :ssl, :ssl_key, :ssl_cert, :ssl_additional_certs, :ssl_host, :ssl_port,
                  :trim_urls, :max_connections
  end

  def self.settings
    @@settings
  end
  
  def self.settings=(x)
    @@settings=x
  end
end
