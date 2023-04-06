module MLserver
  class Request
    def initialize(headers: {}, request:, data: "", client:)
      @headers = headers
      @request = request
      @data = data
      @client = client

      @request_split = @request.split(" ")
    end

    def method
      @request_split[0].upcase
    end

    def path
      @request_split[1]
    end

    def httpver
      @request_split[2]
    end

    def respond(response)
      MLserver.settings.logger.log "#{@client.peeraddr[2]} <= #{response.httpver} #{response.status}"
      @client.puts response.to_s
    end

    attr_reader :headers, :request, :data
  end
end
