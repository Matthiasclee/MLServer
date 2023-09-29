# Config
MLserver uses a config file, usually called `mlserver.conf.rb` in the root of the app.
The config file contains the code that configures the app settings.
## Creating a config file
In the base directory of your app, create `mlserver.conf.rb`.
Put the following code in the file:
```rb
settings = MLserver::Settings.new # Create a settings object
MLserver.settings = settings # Set it as MLserver's default settings
```
Now, put some basic config settings:
```rb
settings.host = "::" # Host to listen on
settings.port = 8080 # Port
settings.logger = MLserver::DefaultLogger # Logger
```
## All config settings
* `settings.host`
  * Interface/hostname to listen on
  * Default: `0.0.0.0`
* `settings.port`
  * Port to listen on
  * Default: `5555`
* `settings.logger`
  * Logger to use
  * Set as `MLserver::DefaultLogger` for standard logger
  * See [logger][1]
* `settings.force_host`
  * Required HTTP `Host` header values in an array
  * Set as `false` to allow any host
  * EX: `["www.example.com", "example.com"]`
  * EX: `false`
* `settings.handler`
  * Client handler to use
  * See [client handlers][2]
* `settings.ssl`
  * Enable SSL?
  * Default: `nil` or `false`
* `trim_urls`
  * Remove trailing slashes from request paths
  * EX: `/index.html/` => `/index.html`
  * Default: `false`
* `max_connections`
  * Limits the number of concurrent connections
  * Default: `1000`
#### SSL settings
Only required if SSL is enabled
* `settings.ssl_key`
  * SSL key to use
* `settings.ssl_cert`
  * SSL server certificate to use
  * Do *not* put a chain cert here. Only the server cert.
* `settings.ssl_additional_certs`
  * Array of additional SSL certificates to use (chains, CAs, etc.)
  * Default: `[]`
* `settings.ssl_port`
  * SSL port
* `settings.ssl_host`
  * Interface/hostname for SSL server to listen on

[1]: logger.md
[2]: clienthandlers.md
