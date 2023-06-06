# Responses
## Creating a response
### Normal response
Create a normal response as follows:
```rb
r = MLserver::Response.new(
  status: 200, # Numerical status code
  headers: {}, # Key/value pair headers
  data: "", # Response data
  content_type: "text/html", # Response content type
  httpver: "HTTP/1.1" # Response HTTP version
)
```
### Error response
You can also create an error response like this:
```rb
r = MLserver::ErrorResponse.new(
  404, # Error code
  message: "That file doesn't exist", # Optional error message
  httpver: "HTTP/1.0" # HTTP version (Default 1.0)
)
```
To get the `Response` object from an `ErrorResponse`:
```rb
r.response
```
### Redirect response
To redirect a user, you can return a `RedirectResponse`:
```rb
r = MLserver::RedirectResponse.new(
  "https://cool-website.local", # Destination URL
  type: 302, # Type of redirect (Default 302)
  httpver: "HTTP/1.1" # HTTP version to use (Default 1.1)

# Not yet supported: 300
)
```
To get the `Response` object from a `RedirectResponse`:
```rb
r.response
```
## Responding with a response
To respond with a response, use the `Request#respond` method as follows:
```rb
# ...
response.respond r
```
