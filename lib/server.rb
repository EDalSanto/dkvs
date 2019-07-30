# frozen_string_literal: true

require "socket"
require "pry"
require_relative "request_handler"
require_relative "file_store"

# handle client requests
class Server
  attr_accessor :file_store, :socket, :request_handler
  SOCKET_NAME = "/tmp/dkvs.sock"

  def initialize
    self.file_store = FileStore.new
    self.socket = UNIXServer.new(SOCKET_NAME)
    self.request_handler = RequestHandler.new(file_store)
  end

  def accept_connections
    loop do
      # handle multiple client requests
      Thread.start(socket.accept) do |client|
        yield(client)
        client.close
      end
    end
  end

  def handle(request)
    request_handler.handle(request)
  end

  def shut_down
    File.unlink(SOCKET_NAME)
  end
end
