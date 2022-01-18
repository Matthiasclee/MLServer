# This is my testing server
# Don't expect it to always do anything or work, as it run on my environment.
# You can look at it to learn how to use new/undocumented features or really whatever you want.

$SRV_SETTINGS = {:enable_fw2 => false}
require "./server.rb"

def path(client, data)
	response(client, 200, ["content-type:text/plain"], data["path"])
end

server_params = {
"ssl" => false,
"max-clients" => 10,
#"bind-ipv4" => "192.168.0.191",
"port" => 5555,
"ssl-cert" => "ssl/certificate.crt",
"ssl-key" => "ssl/private.key"
}
start(server_params)
