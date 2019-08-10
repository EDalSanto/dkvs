# frozen_string_literal: true

require "socket"
require "pry"
require_relative "request_handler"
require_relative "file_store"

# handle client requests
class Server
  BASE_SOCKET_PATH = "/tmp/dkvs"
  SOCKET_EXT = "sock"
  attr_accessor :file_store, :socket, :request_handler

  def initialize(socket_name:)
    self.file_store = FileStore.new
    self.socket = UNIXServer.new(full_socket_path(socket_name))
    self.request_handler = RequestHandler.new(file_store)
  end

  def accept_connections
    loop do
      # handle multiple client requests
      # maybe not anymore with LB?
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
    File.unlink(socket.path)
  end

  private

  def full_socket_path(socket_name)
    "#{BASE_SOCKET_PATH}-#{socket_name}.#{SOCKET_EXT}"
  end
end
