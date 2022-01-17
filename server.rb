$ver = "MLServer 0.3.731"
$ver_1 = $ver.split(" ")[1].split(".")[0]
$ver_2 = $ver.split(" ")[1].split(".")[1]
$ver_3 = $ver.split(" ")[1].split(".")[2]
$SRV_SETTINGS = {} if !defined?($SRV_SETTINGS)
$SRV_SETTINGS = {
		:check_for_assets => true,
		:auto_get_new_versions => false,
		:auto_confirm_overwrite => false,
		:warn_if_server_code_not_compatible => true,
		:exit_if_server_code_not_compatible => true,
		:enable_fw2 => false,
		:server_settings_from_argv => false
}.merge($SRV_SETTINGS)
begin
$started_time = Time.now.to_i
puts "#{Time.now.ctime.split(" ")[3]} | MLServer #{$ver}"
require "socket"
require "openssl"
require "net/http"
require "csv"
$clients = [] #Array that stores all open clients
$aacl = true
if $SRV_SETTINGS[:check_for_assets]
	if Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/server.rb")) != File.read(__FILE__)
		puts "#{Time.now.ctime.split(" ")[3]} | A new version of MLServer is available (#{eval Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/server.rb")).split("\n")[0].sub("$", "new_")})"
		if $SRV_SETTINGS[:auto_get_new_versions]
			puts "#{Time.now.ctime.split(" ")[3]} | Fetching new version"
			newver = Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/server.rb"))
			if $SRV_SETTINGS[:auto_confirm_overwrite]
				puts "#{Time.now.ctime.split(" ")[3]} | auto_confirm_overwrite is on; skipping confirmation"
			else
				print "#{Time.now.ctime.split(" ")[3]} | Confirming update of current server file (Y/n) "
			end
			if $SRV_SETTINGS[:auto_confirm_overwrite] || gets.chomp.downcase == "y"
				print "#{Time.now.ctime.split(" ")[3]} | Writing new version... "
				begin
					File.write(__FILE__, newver)
					puts "Done!"
				rescue
					puts "Fail"
					puts "Oops, something went wrong. Please ensure that #{$0} has access to write to #{File.dirname(__FILE__)}"
				end
				puts "#{Time.now.ctime.split(" ")[3]} | Updated, please restart the program."
				exit
			else
				puts "#{Time.now.ctime.split(" ")[3]} | Update cancelled"
			end
		end
	end
	puts "#{Time.now.ctime.split(" ")[3]} | Checking for assets..."
	if !File.directory?("./.server_assets")
		print "#{Time.now.ctime.split(" ")[3]} | Creating assets directory... "
		Dir.mkdir(".server_assets")
		puts "Done"
	end
	if !File.directory?("./.server_assets/fw2")
		print "#{Time.now.ctime.split(" ")[3]} | Creating fw2 directory... "
		Dir.mkdir(".server_assets/fw2")
		puts "Done"
	end
	if !File.directory?("./.server_assets/HTML")
		print "#{Time.now.ctime.split(" ")[3]} | Creating HTML directory... "
		Dir.mkdir(".server_assets/HTML")
		puts "Done"
	end
	if !File.directory?("./.server_assets/server_code")
		print "#{Time.now.ctime.split(" ")[3]} | Creating server code directory... "
		Dir.mkdir(".server_assets/server_code")
		puts "Done"
	end
	if !File.exists?("./.server_assets/server_assets.txt")
		print "#{Time.now.ctime.split(" ")[3]} | Fetching server assets list... "
		File.write("./.server_assets/server_assets.txt", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/.server_assets/server_assets.txt")))
		puts "Done"
	end
	for asset in File.read("./.server_assets/server_assets.txt").split("\n") do
		asset = asset.split("|")
		if !File.exist?(asset[0])
			print "#{Time.now.ctime.split(" ")[3]} | Fetching #{asset[1]}... "
			File.write(asset[0], Net::HTTP.get(URI.parse(asset[2])))
			puts "Done"
		end
	end
end
require "./.server_assets/server_code/local_debug.rb"
require "./.server_assets/server_code/client_handler.rb"
require "./.server_assets/server_code/args.rb"
if $SRV_SETTINGS[:enable_fw2]
	require "./.server_assets/fw2/main.rb"
end
args = Arg.new(ARGV).args
srv_settings_from_args = args
args.each{
	|arg|
	if arg[1].class != :sym.class
		if arg[1].downcase == "true" || arg[1].downcase == "1" || arg[1].downcase == "y" || arg[1].downcase == "t"
			srv_settings_from_args[arg[0]] = true
		elsif arg[1].downcase == "false" || arg[1].downcase == "0" || arg[1].downcase == "n" || arg[1].downcase == "f"
			srv_settings_from_args[arg[0]] = false
		end
	end
}
if args[:no_cli] && __FILE__ == $0
	exit
end
if $SRV_SETTINGS[:server_settings_from_argv]
	$SRV_SETTINGS = $SRV_SETTINGS.merge(srv_settings_from_args)
end
flagged_to_exit = false
def compat?(srv, addon)
	if srv[0] != addon[0] && addon[0] != "x"
		return false
	end
	if srv[1] != addon[1] && addon[1] != "x"
		return false
	end
	if srv[2] != addon[2] && addon[2] != "x"
		return false
	end
	return true
end
if !compat?([$ver_1, $ver_2, $ver_3], [$CH_COMPAT_VER_0, $CH_COMPAT_VER_1, $CH_COMPAT_VER_2]) && $SRV_SETTINGS[:warn_if_server_code_not_compatible]
	puts "#{Time.now.ctime.split(" ")[3]} | WARN: The current client handler is not compatible with the current MLServer version (#{$ver}). Plese update it."
	flagged_to_exit = true if $SRV_SETTINGS[:exit_if_server_code_not_compatible]
end
if !compat?([$ver_1, $ver_2, $ver_3], [$LD_COMPAT_VER_0, $LD_COMPAT_VER_1, $LD_COMPAT_VER_2]) && $SRV_SETTINGS[:warn_if_server_code_not_compatible]
	puts "#{Time.now.ctime.split(" ")[3]} | WARN: The current local debug script is not compatible with the current MLServer version (#{$ver}). Plese update it."
	flagged_to_exit = true if $SRV_SETTINGS[:exit_if_server_code_not_compatible]
end
if !compat?([$ver_1, $ver_2, $ver_3], [$AG_COMPAT_VER_0, $AG_COMPAT_VER_1, $AG_COMPAT_VER_2]) && $SRV_SETTINGS[:warn_if_server_code_not_compatible]
	puts "#{Time.now.ctime.split(" ")[3]} | WARN: The current args parser is not compatible with the current MLServer version (#{$ver}). Plese update it."
	flagged_to_exit = true if $SRV_SETTINGS[:exit_if_server_code_not_compatible]
end
exit if flagged_to_exit
#Close client and remove from array
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
		puts "#{Time.now.ctime.split(" ")[3]} | Client had error #{error.to_s} with no error message provided."
	end
	#Convert error code to integer
	error = error.to_i
	if error == 404
		response(client, 404, ["content-type: text/html"], File.read("./.server_assets/HTML/404.html"))
	elsif error == 500 && errmsg
		response(client, 500, ["content-type: text/html"], File.read("./.server_assets/HTML/500_error.html").gsub("<ERR>", errmsg))
	elsif error == 500
		response(client, 500, ["content-type: text/html"], File.read("./.server_assets/HTML/500.html"))
	else
		response(client, error, ["content-type: text/html"], File.read("./.server_assets/HTML/error_default.html").gsub("<ERRORCODE>", error.to_s))
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
rescue Interrupt
	puts "\nExiting"
	exit
end

def start(params = {"host" => "0.0.0.0", "port" => 80})
	#Define all undefined server parameters
	$ip_protocols = []
	enable_ipv6 = true
	if !params["host"] == nil
		puts "#{Time.now.ctime.split(" ")[3]} | WARN: parameter 'host' has been deprecated and will be removed in future releases. Please use bind-ipv[4, 6] instead."
		params["bind-ipv4"] = params["host"]
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
	elsif params["ssl"]
		
		puts "#{Time.now.ctime.split(" ")[3]} | WARN: SSL is not fully supported yet, do not deploy with SSL."
	end
	if params["ssl-key"] == nil && params["ssl"] == true
		puts "#{Time.now.ctime.split(" ")[3]} | ERROR: SSL key not provided; starting server without ssl"
		raise "MLServer::SSL_LOAD_ERR"
		params["ssl"] = false
	end
	if params["ssl-cert"] == nil && params["ssl"] == true
		puts "#{Time.now.ctime.split(" ")[3]} | ERROR: SSL cert not provided; starting server without ssl"
		raise "MLServer::SSL_LOAD_ERR"
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
	ipv4match = /^((([0-2])?([0-5])?[0-5])|(([0-1])?([0-9])?[0-9]))\.((([0-2])?([0-5])?[0-5])|(([0-1])?([0-9])?[0-9]))\.((([0-2])?([0-5])?[0-5])|(([0-1])?([0-9])?[0-9]))\.((([0-2])?([0-5])?[0-5])|(([0-1])?([0-9])?[0-9]))$/
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

	puts "#{Time.now.ctime.split(" ")[3]} | Starting the server..."
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
	puts "#{Time.now.ctime.split(" ")[3]} | SSL Mode: #{params["ssl"].to_s}"
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
	time = (Time.now.to_i - $started_time)
	puts "#{Time.now.ctime.split(" ")[3]} | Completed in #{time.to_s} second#{"s" if time != 1}."
	if defined?(main) #legacy program support
		puts "#{Time.now.ctime.split(" ")[3]} | Using main() to house your program code is deprecated. If main() is defined for other reasons, ignore this message."
		main
	end
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
		rescue OpenSSL::SSL::SSLError
			puts "#{Time.now.ctime.split(" ")[3]} | Client had SSL error."
		rescue Interrupt
			puts "\nExiting"
			exit
		rescue => error
			begin
				error(client, 500, error)
			rescue
				puts "#{Time.now.ctime.split(" ")[3]} | Client had fatal error. Server is stopping."
				exit
			end
		end
	end
end
if ARGV[0] && File.directory?(ARGV[0]) && __FILE__ == $0
	require ARGV[0] + "/main.rb"
elsif __FILE__ == $0
	require "./.server_assets/server_code/MLServer_cli.rb"
end