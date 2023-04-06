module MLserver
  class Logger
    @@log_levels = [:info, :warn, :error]

    def initialize(out:, err:, log_colors: {}, outputs: {error: :err})
      @out = out
      @err = err
      @log_colors = log_colors
      @outputs = outputs
    end

    def log(message, level = :info)
      out = @out
      out = @err if @outputs[level] == :err

      if @log_colors[level]
        message = message.color @log_colors[level]
      end
      out.puts message
    end

    def format_ip_address(address)
      ipv4_re = /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/
      ipv4_anywhere_re = /((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/
      ipv4_in_ipv6_re = /^(\:\:ffff\:)((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/
      ipv6_re = /(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/

      return address if address.match?(ipv4_re)
      if address.match?(ipv4_in_ipv6_re)
        ipv4_address = address.match(ipv4_anywhere_re).to_s
        return ipv4_address
      end
      if address.match?(ipv6_re)
        return "[#{address}]"
      end
    end

    def log_traffic(ip, direction, data)
      symbol = (direction == :incoming ? "=>" : "<=")

      log("#{format_ip_address ip} #{symbol} #{data}")
    end
  end

  dlcolors = {
    warn: :yellow,
    error: :red
  }

  DefaultLogger = Logger.new(out: STDOUT, err: STDERR, log_colors: dlcolors)
end
