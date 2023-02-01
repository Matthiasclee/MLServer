module MLserver
  module Server
    def self.start(host: "0.0.0.0", port: 80, handler:, logger:)
      server = TCPServer.new(host, port)

      loop do
        Thread.start(server.accept) do |client|
          r=RequestParser.parse_request(client)
          logger.log "#{client.peeraddr[2]} => #{r.method} #{r.path}"
          handler.run(r, client)
        end
      end
    end
  end
end
