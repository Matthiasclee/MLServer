module MLserver
  module Server
    def self.start(host: "0.0.0.0", port: 80, handler:, logger:)
      logger.log "MLserver #{MLserver.version}"

      server = TCPServer.new(host, port)

      logger.log "Listening on #{host}:#{port}"

      loop do
        Thread.start(server.accept) do |client|
          r=RequestParser.parse_request(client)

          if r.httpver != "HTTP/1.0" || httpver != "HTTP/1.1"
            client_ip = client.peeraddr[2]

            resp = MLserver::ErrorResponse.new(505)
            client.puts resp.response.to_s
            client.close

            logger.log_err "Closed connection from #{client_ip}: Unsupported HTTP method (#{r.httpver})"

            Thread.exit
          end

          logger.log "#{client.peeraddr[2]} => #{r.method} #{r.path}"
          handler.run(r, client)
        end
      end
    end
  end
end
