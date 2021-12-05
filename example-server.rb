require "./server.rb"

def main()
	def path(client, data)
		html = "
		<title>Example</title>
		<h1>Hello World!</h1>
		"
		response(client, 200, ["Content-type: text/html"], html)
	end
end


server_params = {
"ssl" => false, #This is not necessary.
"max-clients" => 1
}
start(server_params)