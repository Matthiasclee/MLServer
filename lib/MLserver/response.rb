module MLserver
  class Response
    @@default_headers = {
      Server: "MLserver #{MLserver.version}",
      "Content-Type": "text/plain"
    }

    def initialize(status:200, headers:{}, data:"", content_type: nil, httpver: "HTTP/1.1")
      @status = status
      @data = data
      @httpver = httpver
      @headers = @@default_headers.merge(response_specific_headers).merge(headers)
      @headers[:"Content-Type"] = content_type if content_type
    end

    def to_s(array:false)
      status_line = "#{httpver} #{status}"
      headers = @headers.map { |header|
        k=header[0].to_s
        v=header[1].to_s
        header = "#{k}: #{v}"
      }
      headers = headers.join("\r\n") if !array
      data = @data

      return "#{status_line}\r\n#{headers}\r\n\r\n#{data}\r\n" if !array
      return [status_line, headers, "", data, ""] if array
    end

    attr_accessor :status, :headers, :data, :httpver

    private

    def response_specific_headers
      {
        Date: Time.now.strftime("%a, %d %b %Y %H:%M:%S %Z"),
        "Content-Length": @data.length,
      }
    end
  end
end
