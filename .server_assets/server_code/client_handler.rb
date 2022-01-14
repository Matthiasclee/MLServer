$ch_ver = "0.0.1"
def clientHandler(client, params)
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
				data = {"request" => req, "headers" => $headers, "remote_ip" => remote_ip, "path" => path.split("?")[0], "get_params" => gp_final, "method" => type, "data" => data, "cookies" => cookies}
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