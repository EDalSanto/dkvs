# frozen_string_literal: true

require "socket"
require_relative "request_handler"
require_relative "file_store"

# handle client requests
class Server
  REPLICA_SOCKET_PATH = "/tmp/dkvs-replica-server.sock"
  attr_accessor :up, :file_store, :socket, :request_handler

  def initialize
    self.file_store = FileStore.new(path: file_path)
    self.socket = UNIXServer.new(socket_path)
    self.request_handler = RequestHandler.new(self)
    self.up = true
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

  # should probably be on WAL or WAL process
  def replicate(request)
    UNIXSocket.new(REPLICA_SOCKET_PATH).puts(request)
  end

  def handle(request)
    request_handler.handle(request)
  end

  def shut_down
    return true if !up

    File.unlink(socket.path)
    socket.close
    self.up = false

    true
  end

  private

  def file_path
    raise "Implemented in SubClass"
  end

  def socket_path
    raise "Implemented in SubClass"
  end
end
