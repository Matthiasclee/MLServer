# Client Handlers
To make a working website, you need to have a client handler that
processes the request and makes a response.

## Creating a client handler
Create a new ruby file in the same directory as the config file.
In this file, make a new `MLserver::ClientHandler`, and set it as
a constant. Pass it a block, and have it take in two variables: `rq`
and `c`. `rq` is the client's request (see [requests][2]), and `c` is the client itself.
```rb
Handler = MLserver::ClientHandler.new do |rq, c|
end
```

Now, put some code in the client handler.
```rb
Handler = MLserver::ClientHandler.new do |rq, c|
  r = MLserver::Response.new( # Create a new response
    status: 200, # Set the status to 200 OK
    data: c.peeraddr[2], # Respond with the client's IP address
    content_type: "text/plain" # Respond with the text/plain content type
  )

  r.httpver = rq.httpver # Respond with the same HTTP version as the client
  rq.respond r # Send the response
end
```

## Using the client handler
Now that we have a client handler, we have to actually use it by specifying it in the settings.
<br>
`mlserver.conf.rb`
```rb
settings = MLserver::Settings.new
MLserver.settings = settings

# ...

# Client handler
require_relative "app.rb" # Require the file with the client handler
settings.handler = Handler # Set the client handler
```
(See [config][1])
[1]: https://github.com/Matthiasclee/MLServer/blob/master/docs/config.md
[2]: https://github.com/Matthiasclee/MLServer/blob/master/docs/requests.md
