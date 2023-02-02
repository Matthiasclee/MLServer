module MLserver
  module Server
    @@valid_http_versions = ["HTTP/1.0", "HTTP/1.1"]

    def self.start(host: "0.0.0.0", port: 80, handler:, logger:)
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

            logger.log "#{client.peeraddr[2]} => #{r.method} #{r.path}"
            handler.run(r, client)

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
