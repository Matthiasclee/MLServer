module MLserver
  module Server
    def self.start(host: "0.0.0.0", port: 80)
      server = TCPServer.new(host, port)

      loop do
        Thread.start(server.accept) do |client|
          r=RequestParser.parse_request(client)
          client.puts Response.new(data: "a").to_s
        end
      end
    end
  end
end
