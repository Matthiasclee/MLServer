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

      server = TCPServer.new(host, port)

      logger.log "Listening on #{host}:#{port}"

      loop do
        Thread.start(server.accept) do |client|
          loop do
            r=RequestParser.parse_request(client)

            if !@@valid_http_versions.include?(r.httpver)
              client_ip = client.peeraddr[2]

              resp = MLserver::ErrorResponse.new(505)
              client.puts resp.response.to_s
              client.close

              logger.log_err "Closed connection from #{client_ip}: Unsupported HTTP method (#{r.httpver})"

              Thread.exit
            end

            logger.log "#{client.peeraddr[2]} => #{r.method} #{r.path} #{r.httpver}"
            handler.run(r, client)

            if r.httpver == "HTTP/1.1"
              if !r.headers[:Host]
                client.puts ErrorResponse.new(400).response.to_s
                client.close
                Thread.exit
              elsif settings.force_host
                if !settings.force_host.include?(r.headers[:Host])
                  client.puts ErrorResponse.new(400).response.to_s
                  client.close
                  Thread.exit
                end
              end
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
