module MLserver
  class Logger
    def initialize(out:, err:)
      @out = out
      @err = err
    end

    def log(message)
      @out.puts message
    end

    def log_err(message)
      @err.puts message
    end
  end

  DefaultLogger = Logger.new(out: STDOUT, err: STDERR)
end
