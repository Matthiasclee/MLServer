$fw2_ver = "0.0.1 BETA"

$currentclient = nil
def path(client, data)
	$currentclient = client
	if data["method"].upcase == "GET"
		if $get_paths.keys.include?(data["path"])
			$get_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "HEAD"
		if $head_paths.keys.include?(data["path"])
			$head_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "POST"
		# postdat = {}
		# for parameter in data["data"].split("&") do
		# 	postdat[parameter.split("=")[0]] = parameter.split("=")[1]
		# end
		if $post_paths.keys.include?(data["path"])
			$post_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "PUT"
		if $put_paths.keys.include?(data["path"])
			$put_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "DELETE"
		if $delete_paths.keys.include?(data["path"])
			$delete_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "CONNECT"
		if $connect_paths.keys.include?(data["path"])
			$connect_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "OPTIONS"
		if $options_paths.keys.include?(data["path"])
			$options_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "TRACE"
		if $trace_paths.keys.include?(data["path"])
			$trace_paths[data["path"]].call(client, data)
		end
	end
	if data["method"].upcase == "PATCH"
		if $patch_paths.keys.include?(data["path"])
			$patch_paths[data["path"]].call(client, data)
		end
	end
end
$get_paths = {}
$head_paths = {}
$post_paths = {}
$put_paths = {}
$delete_paths = {}
$connect_paths = {}
$options_paths = {}
$trace_paths = {}
$patch_paths = {}
def get(path, &block)
	$get_paths[path] = block
end
def head(path, &block)
	$head_paths[path] = block
end
def post(path, &block)
	$post_paths[path] = block
end
def put(path, &block)
	$put_paths[path] = block
end
def delete(path, &block)
	$delete_paths[path] = block
end
def connect(path, &block)
	$connect_paths[path] = block
end
def options(path, &block)
	$options_paths[path] = block
end
def trace(path, &block)
	$trace_paths[path] = block
end
def patch(path, &block)
	$patch_paths[path] = block
end
$start_params = {
	"remove-trailing-slash" => true,
	"port" => 5555
}
def fw2_start(params = {})
	$start_params = $start_params.merge(params)
	start($start_params)
end