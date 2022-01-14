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
"host" => "127.0.0.1",
"port" => 5555,
"ssl-cert" => "ssl/certificate.crt",
"ssl-key" => "ssl/private.key"
}
fw2_start(server_params)