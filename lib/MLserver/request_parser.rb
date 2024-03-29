module MLserver
  module RequestParser
    def self.parse_request(client)
      keepReading = true
      headers = {}
      data = ""

      req = client.gets.to_s

      while req.gsub("\r\n", "") == "" do
        req = client.gets.to_s
      end

      #Close if bad request
      if req.to_s.length < 14
        client.puts ErrorResponse.new(400).response.to_s
        client.close
        Thread.exit
      end

      #Get all headers
      while keepReading do
        x = client.gets.to_s
        if x.chomp.length == 0
          keepReading = false
        else
          if x.split(": ").length < 2
            client.puts ErrorResponse.new(400).response.to_s
            client.close
            Thread.exit
          end
          headers[x.split(": ")[0].to_sym] = x.split(": ")[1].chomp
        end
      end

      #Get payload data
      data = client.read(headers[:"Content-Length"].to_i)

      return Request.new(headers: headers, request: req, data: data, client: client)
    end
  end
end
