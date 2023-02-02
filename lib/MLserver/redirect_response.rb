module MLserver
  class RedirectResponse
    def initialize(url, type: 302, httpver: "HTTP/1.1")
      @type = type.to_i
      @url = url.to_s
      @httpver = httpver
    end

    def response
      return Response.new(status: @type, headers: {Location: @url}, data: "Redirecting... If you don't get redirected, go to the following URL: #{@url}", httpver: @httpver)
    end
  end
end
