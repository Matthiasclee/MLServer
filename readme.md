# MLServer

## What is MLServer?
MLserver is a simple, easy to use webserver that allows for infinite flexibility

## How to install
To use MLServer in your project, start out with downloading the [main MLServer script](https://raw.githubusercontent.com/Matthiasclee/MLServer/main/server.rb). You can either put it in your project folder and include it with ```require "./server.rb"``` or add it to a directory in your ```$LOAD_PATH```. MLServer will download all of its dependencies upon being run for the first time.

## How to use MLServer
Using MLServer is pretty straightforward. When your server receives a request, it calls the ```path()``` function and passes it the client that made the request, and a whole bunch of data that MLServer gathered about the request, including the path, headers, cookies, etc.

### Getting Started
To get started, define a ```path()``` function that takes in two variables, ```client```, and ```data```.

```rb
require "./server.rb"

def path(client, data)

end
```

### Sending responses
Inside of the ```path()``` function, your program will take in the data, and generate a response. You can send the http response back using the ```response()``` method.

```resopnse()``` takes 4 arguments: the client (passed to the ```path()``` function), the response code, the headers, and the actual data.

```rb
response(client, 200, ["content-type: text/html"], "<h1>Hello World!</h1>")
```

Including that code above inside of ```path()``` will send back

```html
<h1>Hello World!</h1>
```

to your browser, which will display "Hello World!" in large text when your server is visited in a web browser.

### Redirects
MLServer also supports sending built in redirect responses so you don't need to make the whole thing yourself using the ```redirect()``` method.

```rb
redirect(client, "https://google.com")
```

### Error responses
When the server encounters an internal error, error code 500 will automatically be sent to the client, but for other errors (404, 405) that are determined by your code, you need to call the error yourself. You could run 

```rb
response(client, 404, ["content-type: text/html"], "error 404")
```

to send the 404 page, but there is a faster way.
MLServer comes with an ```error()``` method. With this, you can run

```rb
error(client, 404)
```

to send back the error page, and you will get a default error page that resides in ```<MLServer.rb location>/.server_assets/HTML```. You can modify these files to make custom 404 and 500 pages, or you could write your own error handler by defining ```error()``` yourself. 
```error()``` takes a third argument too: error message. This error message only matters if it's a 500 error, or you want it to be outputted to the terminal, otherwise it doesn't matter.

### Interpreting data
You can of course also read the ```data``` variable passed to the ```path()``` function to generate a specific response. The ```data``` variable looks something like this:

```rb
{
	"request" => "GET / HTTP/1.1\r\n", #The request the client made to the server
	"headers" => { #Hash of all headers given by the client
		"Host"=>"127.0.0.1:5555", 
		"Connection"=>"keep-alive", 
		"sec-ch-ua-platform"=>"\"macOS\"", 
		"User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36", 
		"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
	}, 
	"remote_ip"=>"127.0.0.1", #The IP address of the client
	"path"=>"/", #The path the client is requesting
	"get_params"=>{}, #Get parameters (the ?a=b&c=d at the end of a URL)
	"method"=>"GET", #The HTTP method the client is using
	"data"=>"", #The data the client sent along (applicable with POST/PATCH and other HTTP methods)
	"cookies"=>{ #Cookies that can be accessed from that webpage
		"example" => "data"
	}
}
```

With this data, we can make a better program that can give specific responses for specific pages and more.

```rb
require "./server.rb"
def path(client, data)
	if data["method"] == "GET" #Only respond to GET requests
		if data["path"] == "/" #Only send response if the path is "/"
			response(client, 200, ["content-type: text/html"], "<h1>Hello World!</h1>")
		else
			error(client, 404) #Not found error
		end
	else
		error(client, 405) #Invalid method error	
	end
end
```

### Starting the server
Running any one of those code examples will do seemingly nothing. This is for a reason, as the server does not start until you start it. You start the server by putting ```start()``` at the bottom of the code.

```rb
require "./server.rb"
def path(client, data)
	if data["method"] == "GET" #Only respond to GET requests
		if data["path"] == "/" #Only send response if the path is "/"
			response(client, 200, ["content-type: text/html"], "<h1>Hello World!</h1>")
		else
			error(client, 404) #Not found error
		end
	else
		error(client, 405) #Invalid method error	
	end
end

start() #Server will start listening for requests
```

Your shell output will then look like this:

```
15:06:10 | MLServer MLServer 0.3.432
15:06:10 | Checking for assets...
15:06:10 | Starting the server...
15:06:10 | SSL Mode: false
15:06:10 | Server listening on 0.0.0.0:80
15:06:10 | Completed in 0 seconds.
```

as the server actually has started. You now can visit [localhost](http://localhost) in your web browser and see ```Hello World!``` in big font.

### MLServer CLI
If you run ```server.rb``` or whatever file MLServer is saved as, you can use the MLServer CLI. The CLI is limited as of now. It has 4 commands:

```
exit
start
ver
update_check
```

#### exit
The ```exit``` command is used for exiting MLServer CLI.

#### start
The ```start``` command is used to start the server. 
It uses ```main.rb``` in whatever directory was passed as the main program.

#### ver
The ```ver``` command prints the current MLServer version.

#### update_check
The ```update_check``` command checks for and updates MLServer.

### Server parameters
You can start the server with parameters by passing a hash to the ```start()``` function. The supported parameters are as follows:

```
"host" => string
"bind-ipv4" => string
"bind-ipv6" => string
"ipv4" => bool
"ipv6" => bool
"max-clients" => int
"remove-trailing-slash" => bool
"always-add-content-length" => bool
"ssl" => bool
"ssl-key" => string
"ssl-cert" => string
"port" => int
```

#### Binding
You can use server parameters to set the server's bind address(es) and port.
Using ```bind-ipv4```, you can set the server's ipv4 listening address. 
Using ```bind-ipv6```, you can set the server's ipv4 listening address.
Using ```port```, you can set the server's listening port.
All bind addresses can be domain names too, including localhost.

```rb
start_params = {
	"bind-ipv4" => "127.0.0.1",
	"bind-ipv6" => "::1",
	"port" => 8080
}

start(start_params)
```

#### IPv4 and IPv6
You can enable/disable use of the IPv4 and IPv6 protocols via the ```ipv4``` and ```ipv6``` parameters. By default only IPv4 is enabled.

```rb
start_params = {
	"ipv4" => true,
	"ipv6" => true
}

start(start_params)
```

#### Max Clients
To limit server throttling, you can set the ```max-clients``` parameter to any positive integer (negitaves set no limit). This parameter limits the concurrent conenctions to the server at any given moment. (default -1)
NOTE: this is only useful for large scale deployments receiving lots of traffic.

```rb
start_params = {
	"max-clients" => 10
}

start(start_params)
```

#### Remove Trailing Slash
This parameter is pretty simple, when enabled, all requests to a non-root path that have an extra slash at the end are automatically redirected to the same URL, but with no extra slash. (default off)

```rb
start_params = {
	"remove-trailing-slash" => true
}

start(start_params)
```

#### Always Add Content Length
This parameter is pretty straightforward: it automatically adds the content-length header to all responses (default on)

```rb
start_params ={
	"always-add-content-length" => false
}

start(start_params)
```

#### SSL
MLServer, although still experimental _does_ support use of SSL.
Enabling it is pretty straightfoward: you set ```ssl``` to true, and set ```ssl-key``` and ```ssl-cert``` to paths to ssl keys and certificates. 

```rb
start_params = {
	"ssl" => true,
	"ssl-key" => "./ssl/priv.key",
	"ssl-cert" => "./.ssl/cert.crt"
}
```

If done correctly, your shell output should look like this:

```
15:39:54 | MLServer MLServer 0.3.441
15:39:55 | Checking for assets...
15:39:55 | WARN: SSL is not fully supported yet, do not deploy with SSL.
15:39:55 | Starting the server...
15:39:55 | SSL Mode: true
15:39:55 | Server listening on 0.0.0.0:443
15:39:55 | Completed in 1 second.
```
