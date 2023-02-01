module MLserver
  module Server
    def self.start(host: "0.0.0.0", port: 80)
      server = TCPServer.new(host, port)

      x=server.accept
      r=RequestParser.parse_request(x)
      x.puts Response.new(data: "a").to_s
    end
  end
end
