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
  end

  DefaultLogger = Logger.new(out: STDOUT, err: STDERR)
end
