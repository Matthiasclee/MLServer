module MLserver
  class ErrorResponse
    @@error_messages_by_code = {
      400 => "bad request",
      401 => "unauthorized",
      403 => "forbidden",
      404 => "page not found",
      405 => "method not allowed",
      406 => "not acceptable",
      407 => "proxy authentication required",
      408 => "request timeout",
      409 => "conflict",
      410 => "resource gone",
      411 => "length required",
      412 => "precondition failed",
      413 => "payload too large",
      414 => "URI too long",
      415 => "unsupported media type",
      416 => "range not satisfiable",
      417 => "expectation failed",
      418 => "I'm a teapot",
      421 => "misdirected request",
      422 => "unprocessable entity",
      423 => "resource locked",
      424 => "failed dependency",
      425 => "too early",
      426 => "upgrade required",
      428 => "precondition required",
      429 => "too many requests",
      431 => "request header fields too large",
      451 => "unavailable for legal reasons",
      500 => "internal server error",
      501 => "not implemented",
      502 => "bad gateway",
      503 => "service unavailable",
      504 => "gateway timeout",
      505 => "HTTP version not supported",
      506 => "variant also negotiates",
      507 => "insufficient storage",
      508 => "loop detected",
      510 => "not extended",
      511 => "network authentication required"
    }

    def initialize(code, message: nil)
      code = code.to_i
      @code = code
      @message = message ? message : "Error: #{code} (#{@@error_messages_by_code[code]})"
    end

    def response
      return Response.new(status: @code, data: html_page, content_type: "text/html")
    end

    def html_page
      return File.read(File.dirname(__FILE__) + "/html/error_page.template.html").gsub("[ecode]", @code.to_s).gsub("[emsg]", @message)
    end
  end
end
