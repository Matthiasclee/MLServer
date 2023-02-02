module MLserver
  class RedirectResponse
    def initialize(url, type: 302)
      @type = type.to_i
      @url = url.to_s
    end

    def response
      return Response.new(status: @type, headers: {Location: @url}, data: "Redirecting... If you don't get redirected, go to the following URL: #{@url}")
    end
  end
end
