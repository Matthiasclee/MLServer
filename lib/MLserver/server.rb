module MLserver
  module Server
    @@valid_http_versions = ["HTTP/1.0", "HTTP/1.1"]

    def self.start
      settings = MLserver.settings

      host = settings.host
      port = settings.port
      handler = settings.handler
      logger = settings.logger

      logger.log "MLserver #{MLserver.version}"

      #SSL
      logger.log "Starting SSL"

      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(settings.ssl_cert).read)
      ssl_context.key = OpenSSL::PKey::RSA.new(File.open(settings.ssl_key).read)

      store = OpenSSL::X509::Store.new
      settings.ssl_additional_certs.each do |c|
        store.add_cert(OpenSSL::X509::Certificate.new(File.open(c).read))
      end

      ssl_context.cert_store = store

      tcp_server = TCPServer.new(host, port)

      server = OpenSSL::SSL::SSLServer.new(tcp_server, ssl_context)
      #SSL_END

      logger.log "Listening on #{logger.format_ip_address host}:#{port}"

      loop do
        begin
          client = server.accept
        rescue OpenSSL::SSL::SSLError => e
          logger.log "SSL error occured: #{e}", :error
          client.close if client
          next
        end

        Thread.start(client) do |client|
          loop do
            #if !client.is_a?(OpenSSL::SSL::SSLSocket)
            #  logger.log "HTTP connection to HTTPS server from #{logger.format_ip_address client.peeraddr[2]}", :error
            #  client.close
            #  Thread.exit
            #end

            r=RequestParser.parse_request(client)

            logger.log_traffic client.peeraddr[2], :incoming, "#{r.method} #{r.path} #{r.httpver}"

            if !@@valid_http_versions.include?(r.httpver)
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
  end
end
