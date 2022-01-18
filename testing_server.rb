# This is my testing server
# Don't expect it to always do anything or work, as it run on my environment.
# You can look at it to learn how to use new/undocumented features or really whatever you want.

$SRV_SETTINGS = {:enable_fw2 => true}
require "./server.rb"

get("/") do |client, data|
	response(client, 200, ["content-type: text/html"], "hi")
end
get("/hi") do |client, data|
	response(client, 200, ["content-type: text/html"], "hello")
end


server_params = {
"ssl" => false,
"max-clients" => 10,
"host" => "192.168.0.228",
"port" => 5555,
"ssl-cert" => "ssl/certificate.crt",
"ssl-key" => "ssl/private.key"
}
fw2_start(server_params)