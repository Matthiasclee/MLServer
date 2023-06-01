# Logger
## Default Logger
The default logger is `MLserver::DefaultLogger`. It has the following settings:
#### Levels
* `info`
* `warn`
* `error`
* `traffic_in`
* `traffic_out`
#### Log colors
* `info`: default
* `warn`: yellow
* `error`: red
* `traffic_in`: green
* `traffic_out`: blue
#### Timestamped levels
* `traffic_in`
* `traffic_out`
#### Levels redirected to STDERR
* `error`
#### Default output locations
* `STDOUT`
* `STDERR`
## Creating a logger
Create a logger as follows:
```rb
# Define colors for different log levels
dlcolors = {
  warn: :yellow,
  error: :red,
  traffic_in: :green,
  traffic_out: :blue
}

logger = MLserver::Logger.new(
  out: STDOUT, # Location of normal logs
  err: STDERR, # Location of error logs
  log_colors: dlcolors,
  outputs: { # Which logs go to error
    error: :err
  },
  levels_with_timestamp: [ # Which log levels get timestamped
    :traffic_in,
    :traffic_out
  ]
)
```
