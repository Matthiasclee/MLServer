module MLserver
  module Server
    @@valid_http_versions = ["HTTP/1.0", "HTTP/1.1"]

    def self.start
      settings = MLserver.settings

      host = settings.host
      port = settings.port
      ssl_host = settings.ssl_host
      ssl_port = settings.ssl_port
      handler = settings.handler
      logger = settings.logger
      @@use_http_versions = @@valid_http_versions - (@@valid_http_versions - settings.use_http_versions)

      logger.log "MLserver #{MLserver.version}"

      http_server = TCPServer.new(host, port)
      logger.log "Listening on #{logger.format_ip_address host}:#{port}"

      if settings.ssl
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(settings.ssl_cert).read)
        ssl_context.key = OpenSSL::PKey::RSA.new(File.open(settings.ssl_key).read)

        store = OpenSSL::X509::Store.new
        settings.ssl_additional_certs.each do |c|
          store.add_cert(OpenSSL::X509::Certificate.new(File.open(c).read))
        end

        ssl_context.cert_store = store

        tcp_server = TCPServer.new(ssl_host, ssl_port)

        ssl_server = OpenSSL::SSL::SSLServer.new(tcp_server, ssl_context)
        logger.log "Listening with SSL on #{logger.format_ip_address ssl_host}:#{ssl_port}"
      end

      if settings.ssl
        Thread.new do
          loop do
            begin
              client = ssl_server.accept
            rescue OpenSSL::SSL::SSLError => e
              logger.log "SSL error occured: #{e}", :error
              client.close if client
              next
            rescue Errno::ECONNRESET => e
              logger.log "SSL Connection reset: #{e}", :error
              client.close if client
              next
            end

            Thread.start(client) do |client|
              self.handle_client client
            end
          end
        end
      end

      loop do
        begin
          client = http_server.accept
        rescue OpenSSL::SSL::SSLError => e
          logger.log "SSL error occured: #{e}", :error
          client.close if client
          next
        end

        Thread.start(client) do |client|
          self.handle_client client
        end
      end
    end

    def self.handle_client(client)
      settings = MLserver.settings

      logger = MLserver.settings.logger
      handler = MLserver.settings.handler

      loop do
        r=RequestParser.parse_request(client)

        logger.log_traffic client.peeraddr[2], :incoming, "#{r.method} #{r.path} #{r.httpver}"

        if !@@use_http_versions.include?(r.httpver)
          client_ip = client.peeraddr[2]

          resp = MLserver::ErrorResponse.new(505)
          r.respond resp.response
          client.close

          Thread.exit
        end

        if r.httpver == "HTTP/1.1"
          if !r.headers[:Host]
            r.respond ErrorResponse.new(400).response
            client.close
            Thread.exit
          elsif settings.force_host
            if !settings.force_host.include?(r.headers[:Host])
              r.respond ErrorResponse.new(400).response
              client.close
              Thread.exit
            end
          end
        end

        if MLserver.settings.trim_urls && r.path != "/" && r.path[-1] == "/"
          r.respond RedirectResponse.new(r.path[0..-2], type: 301, httpver: "HTTP/1.0").response
          client.close
          Thread.exit
        end

        begin
          handler.run(r, client)
        rescue => e
          r.respond ErrorResponse.new(500).response
          logger.log "An error occured: #{e.message}", :error
          raise e
        end

        if r.httpver == "HTTP/1.0" || r.headers[:Connection] == "close"
          client.close
          Thread.exit
        end
      end
    end
  end
end
