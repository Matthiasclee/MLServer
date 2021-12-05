def path_debug(client, data)
	if data["method"] != "GET"
		error(client, 405)
	else
		if data["path"] == "/__"
			response(client, 200, ["Content-type: text/html"], File.read("./.server_assets/index.html"))
		elsif data["path"] == "/__/doc"
			response(client, 200, ["Content-type: text/html"], File.read("./.server_assets/doc.html"))
		else
			error(client, 404)
		end
	end
end
