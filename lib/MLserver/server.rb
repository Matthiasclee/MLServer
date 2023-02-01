module MLserver
  module Server
    def self.start(host: "0.0.0.0", port: 80, handler:)
      server = TCPServer.new(host, port)

      loop do
        Thread.start(server.accept) do |client|
          r=RequestParser.parse_request(client)
          handler.run(r, client)
        end
      end
    end
  end
end
