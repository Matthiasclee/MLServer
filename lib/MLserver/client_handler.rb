module MLserver
  class ClientHandler
    def initialize(&block)
      @block = block
    end

    def run(request, client)
      @block.call(request, client)
    end
  end
end
