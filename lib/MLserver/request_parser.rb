module MLserver
  module RequestParser
    def self.parse_request(client)
      keepReading = true
      headers = {}
      data = ""

      req = client.gets

      #Close if bad request
      if req.to_s.length < 3
        #close(client)
        #Thread.exit
      end

      #Get all headers
      while keepReading do
        x = client.gets.to_s
        if x.chomp.length == 0
          keepReading = false
        else
          begin
            headers[x.split(": ")[0]] = x.split(": ")[1].chomp
          rescue => error
            error(client, 500, error)
          end
        end
      end

      #Get payload data
      data = client.read(headers["Content-Length"].to_i)

      return Request.new(headers: headers, request: req, data: data)
    end
  end
end
