module MLserver
  @@settings = nil

  class Settings
    def initialize(host: "0.0.0.0", port: "8080")
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
      @use_http_versions = ["HTTP/1.0", "HTTP/1.1"]
    end

    attr_accessor :host, :port, :handler, :logger, :force_host, :ssl, :ssl_key, :ssl_cert, :ssl_additional_certs, :ssl_host, :ssl_port,
                  :trim_urls, :use_http_versions
  end

  def self.settings
    @@settings
  end
  
  def self.settings=(x)
    @@settings=x
  end
end
