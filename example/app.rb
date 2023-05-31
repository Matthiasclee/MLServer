Handler = MLserver::ClientHandler.new do |rq, c|
  html = File.read("html/index.html")
  html.gsub!("!IP!", MLserver::DefaultLogger.format_ip_address(c.peeraddr[2]))
  r = MLserver::Response.new(status: 200, data: html, content_type: "text/html")

  r.httpver = rq.httpver
  rq.respond r
end
