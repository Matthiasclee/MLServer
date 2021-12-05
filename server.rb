$ver = "MLServer 0.0.2.4 Ruby"
require "./.server_assets/local_debug.rb"
require "socket"
require "openssl"
$clients = [] #Array that stores all open clients
$aacl = true
$apim = false
#Close client and remove from array
def close(client)
	$clients.delete(client)
	client.close
end

#Built in error handler
def error(client, error, errmsg = nil)
	#If error message is provided, print it
	if errmsg != nil
		errmsg = errmsg.to_s
		puts "#{Time.now.ctime.split(" ")[3]} | ERROR: " + errmsg.to_s
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
end

#Redirect the client
def redirect(client, destination = "/")
	response(client, 302, ["Content-Type: text/html", "Location: #{destination.to_s}"], "Redirecting...")
end


def start(params = {"host" => "0.0.0.0", "port" => 80})
#Define all undefined server parameters
if params["host"] == nil
	params["host"] = "0.0.0.0"
end
if params["max-clients"] == nil
	params["max-clients"] = -1
end
if params["remove-trailing-slash"] == nil
	params["remove-trailing-slash"] = false
end
if params["always-add-content-length"] == nil
	params["always-add-content-length"] = true
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
$aacl = params["always-add-content-length"]

params["host"] = params["host"].to_s
params["port"] = params["port"].to_i
$HOST = params["host"].to_s
$PORT = params["port"].to_i
$SSL_PORT = params["ssl-port"].to_i

#Start the server
	tcp_server = TCPServer.new($HOST, $PORT)
	#SSL
	if params["ssl"]
		ctx = OpenSSL::SSL::SSLContext.new
		ctx.key = OpenSSL::PKey::RSA.new File.read params["ssl-key"]
		ctx.cert = OpenSSL::X509::Certificate.new File.read params["ssl-cert"]
		server = OpenSSL::SSL::SSLServer.new(tcp_server, ctx)
	else
		server = tcp_server
	end
	if !$apim
	puts "Server listening on #{$HOST}:#{$PORT.to_s}"
	puts "SSL Mode: #{params["ssl"].to_s}"
	$apim = true
	end
	main
	loop do
		begin
		$serverThread = Thread.start(server.accept) do |client|
			remote_port, remote_hostname, remote_ip = client.peeraddr
			#See if there is room to accept client (-1 max clients sets no limit)
			if $clients.length == params["max-clients"]
				puts "#{Time.now.ctime.split(" ")[3]} | #{remote_ip} was closed: MAX_CLIENTS_REACHED"
				client.close()
				Thread.exit
			end

			#Add client to array
			$clients << client
			keepReading = true
			$headers_list = []
			$headers = {}
			$data = ""
			req = client.gets

			#Close if bad request
			if req.to_s.length < 3
				close(client)
				Thread.exit
			end


			begin
				type = req.split(" ")[0]
				path = req.split(" ")[1]
				httpver = req.split(" ")[2]
				if params["remove-trailing-slash"] == true && path[path.length-1] == "/" && path != "/"
					path_ = path.split("")
					path_[path.length-1] = ""
					redirect(client, path_.join)
				end
			rescue => error
				error(client, 500, error)
			end

			#Get all headers
			puts "#{Time.now.ctime.split(" ")[3]} | #{remote_ip.to_s} => #{type} #{path}"
			while keepReading do
				x = client.gets
				if x.chomp.length == 0
					keepReading = false
				else
					begin
						$headers[x.split(": ")[0]] = x.split(": ")[1].chomp
						$headers_list << x.split(": ")[0]
					rescue => error
						error(client, 500, error)
					end
				end
			end

			#Get Cookies
			if $headers["Cookie"]
				cookies_ = $headers["Cookie"].split("; ")
				cookies = {}
				for c in cookies_ do
					cookies[c.split("=")[0]] = c.split("=")[1]
				end
			else
				cookies = {}
			end

			#Get payload data
			data = client.read($headers["Content-Length"].to_i)

			#Generate response
			get_params = path.split("?")[1].to_s.split("&")
			gp_final = {}
			for x in get_params do
				gp_final[x.split("=")[0]] = x.split("=")[1]
			end
			data = {"request" => req, "headers" => $headers, "remote_ip" => remote_ip, "remote_port" => remote_port, "remote_hostname" => remote_hostname, "path" => path.split("?")[0], "get_params" => gp_final, "method" => type, "data" => data, "cookies" => cookies}
			if path.split("/")[1] == "__" && remote_ip == "127.0.0.1"
				begin
					path_debug(client, data)
				rescue => error
					error(client, 500, error)
				end
			else
				begin
					path(client, data)
				rescue => error
					error(client, 500, error)
				end
			end



			close(client)
		end
		$serverThread.report_on_exception = true
		rescue => $error
			begin
				error(client, 500, error)
			rescue
				puts "#{Time.now.ctime.split(" ")[3]} | Unknown client closed. Possibly tried to connect to ssl server without ssl?"
			end
		end
	end
end
