require "./server.rb"

def path(client, data)
	html = "
	<title>Example</title>
	<h1>Hello World!</h1>
	"
	response(client, 200, ["Content-type: text/html"], html)
end


server_params = {
"max-clients" => 50,
"ipv6" => true,
"bind-ipv6" => "::1",
"port" => 5555,
"ipv4" => false
}
start(server_params)