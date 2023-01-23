module MLserver
  class Request
    def initialize(headers: {}, request:, data: "")
      @headers = headers
      @request = request
      @data = data

      @request_split = @request.split(" ")
    end

    def method
      @request_split[0]
    end

    def path
      @request_split[1]
    end

    def httpver
      @request_split[2]
    end

    attr_reader :headers, :request, :data
  end
end
