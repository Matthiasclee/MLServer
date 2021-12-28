$ver = "MLServer 0.3.42 Ruby"
require "socket"
require "openssl"
require "net/http"
$clients = [] #Array that stores all open clients
$aacl = true
#Close client and remove from array
if !File.directory?("./.server_assets")
	Dir.mkdir(".server_assets")
end
if !File.exists?("./.server_assets/404.html")
	File.write("./.server_assets/404.html", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/404.html")))
end
if !File.exists?("./.server_assets/500.html")
	File.write("./.server_assets/500.html", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/500.html")))
end
if !File.exists?("./.server_assets/500_error.html")
	File.write("./.server_assets/500_error.html", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/500_error.html")))
end
if !File.exists?("./.server_assets/doc.html")
	File.write("./.server_assets/doc.html", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/doc.html")))
end
if !File.exists?("./.server_assets/error_default.html")
	File.write("./.server_assets/error_default.html", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/error_default.html")))
end
if !File.exists?("./.server_assets/index.html")
	File.write("./.server_assets/index.html", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/index.html")))
end
if !File.exists?("./.server_assets/local_debug.rb")
	File.write("./.server_assets/local_debug.rb", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/local_debug.rb")))
end
if !File.exists?("./.server_assets/client_handler.rb")
	File.write("./.server_assets/client_handler.rb", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/client_handler.rb")))
end
require "./.server_assets/local_debug.rb"
require "./.server_assets/client_handler.rb"
def close(client)
	$clients.delete(client)
	begin
		client.close
	rescue
	end
end

#Built in error handler
def error(client, error, errmsg = nil)
	#If error message is provided, print it
	if errmsg != nil
		errmsg = errmsg.to_s
		puts "#{Time.now.ctime.split(" ")[3]} | ERROR: " + errmsg.to_s
	else
		puts "#{Time.now.ctime.split(" ")[3]} | Client had error #{error.to_s} with unknown message."
	end
	#Convert error code to integer
	error = error.to_i
	if error == 404
		response(client, 404, ["content-type: text/html"], File.read("./.server_assets/404.html"))
	elsif error == 500 && errmsg
		response(client, 500, ["content-type: text/html"], File.read("./.server_assets/500_error.html").gsub("<ERR>", errmsg))
	elsif error == 500
		response(client, 500, ["content-type: text/html"], File.read("./.server_assets/500.html"))
	else
		response(client, error, ["content-type: text/html"], File.read("./.server_assets/error_default.html").gsub("<ERRORCODE>", error.to_s))
	end

end

#Form and send a response to the client
def response(client, response = 200, headers = ["Content-Type: text/html"], data = "<h1>No Content Was Provided</h1><br>#{$ver}", aacl = $aacl)
	headers << "Server: MLServer/0.0.1 (Ruby)"
	client.print "HTTP/1.1 #{response.to_s}\r\n"
	headers_s = ""
	for h in headers do
		headers_s = headers_s + h + "\r\n"
	end
	if aacl && !headers_s.downcase.include?("Content-Length: ")
		headers_s = headers_s + "Content-Length: #{data.length.to_s}\n"
	end
	client.print "#{headers_s}\r\n"
	client.print data.to_s
	close(client)
end

#Redirect the client
def redirect(client, destination = "/")
	response(client, 302, ["Content-Type: text/html", "Location: #{destination.to_s}"], "Redirecting...")
end


def start(params = {"host" => "0.0.0.0", "port" => 80})
#Define all undefined server parameters
$ip_protocols = []
enable_ipv6 = true
if !params["host"] == nil
	puts "#{Time.now.ctime.split(" ")[3]} | WARN: parameter 'host' has been deprecated and will be removed in future releases. Please use bind-ipv[4, 6] instead."
end
if params["bind-ipv4"] == nil && params["host"] != nil
	params["bind-ipv4"] = params["host"]
end
if params["bind-ipv4"] == nil
	params["bind-ipv4"] = "0.0.0.0"
end
if params["bind-ipv6"] == nil
	params["bind-ipv6"] = "::"
end
if params["max-clients"] == nil
	params["max-clients"] = -1
end
if params["remove-trailing-slash"] == nil
	params["remove-trailing-slash"] = false
end
if params["always-add-content-length"] == nil
	params["always-add-content-length"] = false
end
if params["ssl"] == nil
	params["ssl"] = false
end
if params["ssl-key"] == nil && params["ssl"] == true
	puts "#{Time.now.ctime.split(" ")[3]} | ERROR: SSL key not provided; starting server without ssl"
	params["ssl"] = false
end
if params["ssl-cert"] == nil && params["ssl"] == true
	puts "#{Time.now.ctime.split(" ")[3]} | ERROR: SSL cert not provided; starting server without ssl"
	params["ssl"] = false
end
if params["port"] == nil
	if params["ssl"]
		params["port"] = 443
	else
		params["port"] = 80
	end
end
if params["ipv6"] == nil
	params["ipv6"] = false
end
if params["ipv4"] == nil
	params["ipv4"] = true
end
domainmatch = /^((([0-9a-zA-Z-]{1,63}\.)+[0-9a-zA-Z-]{2,63})|localhost)$/
ipv4match = /^([0-2])?([0-5])?[0-5]\.([0-2])?([0-5])?[0-5]\.([0-2])?([0-5])?[0-5]\.([0-2])?([0-5])?[0-5]$/
ipv6match = /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/
if !params["bind-ipv4"].match(ipv4match) && !params["bind-ipv4"].match(domainmatch)
	params["ipv4"] = false
	puts "#{Time.now.ctime.split(" ")[3]} | IPv4 address invalid, starting without ipv4"
end
if !params["bind-ipv6"].match(ipv6match) && !params["bind-ipv6"].match(domainmatch)
	params["ipv6"] = false
	puts "#{Time.now.ctime.split(" ")[3]} | IPv6 address invalid, starting without ipv6"
end

$aacl = params["always-add-content-length"]

params["host"] = params["host"].to_s
params["port"] = params["port"].to_i
$HOST_4 = params["bind-ipv4"]
$HOST_6 = params["bind-ipv6"]
$PORT = params["port"].to_i
$SSL_PORT = params["ssl-port"].to_i

#Start the server
	if params["ipv4"]
		tcp_server_4 = TCPServer.new($HOST_4, $PORT)
	end
	if params["ipv6"]
		tcp_server_6 = TCPServer.new($HOST_6, $PORT)
	end
	#SSL
	if params["ssl"] && params["ipv4"]
		ctx = OpenSSL::SSL::SSLContext.new
		ctx.key = OpenSSL::PKey::RSA.new File.read params["ssl-key"]
		ctx.cert = OpenSSL::X509::Certificate.new File.read params["ssl-cert"]
		server_4 = OpenSSL::SSL::SSLServer.new(tcp_server_4, ctx)
	else
		server_4 = tcp_server_4
	end
	if params["ssl"] && params["ipv6"]
		ctx = OpenSSL::SSL::SSLContext.new
		ctx.key = OpenSSL::PKey::RSA.new File.read params["ssl-key"]
		ctx.cert = OpenSSL::X509::Certificate.new File.read params["ssl-cert"]
		server_6 = OpenSSL::SSL::SSLServer.new(tcp_server_6, ctx)
	else
		server_6 = tcp_server_6
	end
	if !params["ipv4"] && !params["ipv6"]
		puts "#{Time.now.ctime.split(" ")[3]} | Server set to listen on no protocols;  stopping"
		exit
	end
	puts "#{Time.now.ctime.split(" ")[3]} | #{$ver}"
	puts "#{Time.now.ctime.split(" ")[3]} | Server listening on #{
		if params["ipv4"] && params["ipv6"]
			"#{$HOST_4}:#{$PORT.to_s} and [#{$HOST_6}]:#{$PORT.to_s}"
		elsif params["ipv4"]
			"#{$HOST_4}:#{$PORT.to_s}"
		elsif params["ipv6"]
			"[#{$HOST_6}]:#{$PORT.to_s}"
		else
			"nothing"
		end
	}"
	puts "#{Time.now.ctime.split(" ")[3]} | SSL Mode: #{params["ssl"].to_s}"
	main
	$lfc4 = true
	$lfc6 = true
	loop do
		begin
			if $lfc4 && params["ipv4"]
				$lfc4 = false
				$serverThread4 = Thread.start(server_4.accept) do |client|
					$lfc4 = true
					clientHandler(client, params)
				end
				$serverThread4.report_on_exception = false
			end
			if $lfc6 && params["ipv6"]
				$lfc6 = false
				$serverThread6 = Thread.start(server_6.accept) do |client|
					$lfc6 = true
					clientHandler(client, params)
				end
				$serverThread6.report_on_exception = false
			end
		rescue => error
			begin
				error(client, 500, error)
			rescue
				puts "#{Time.now.ctime.split(" ")[3]} | Unknown client closed. Possibly tried to connect to ssl server without ssl?"
			end
		end
	end
end
