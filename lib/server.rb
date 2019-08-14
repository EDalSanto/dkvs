# frozen_string_literal: true

require "socket"
require "pry"
require_relative "request_handler"
require_relative "file_store"

# handle client requests
class Server
  BASE_SOCKET_PATH = "/tmp/dkvs"
  SOCKET_EXT = "sock"
  PRIMARY_SOCKET_PATH = "/tmp/dkvs-primary-server.sock"
  REPLICA_SOCKET_PATH = "/tmp/dkvs-replica-server.sock"
  attr_accessor :file_store, :socket, :request_handler, :primary, :socket_path, :wal

  def initialize(primary:)
    self.primary = primary == "true" ? true : false
    self.file_store = FileStore.new(self.primary)
    self.wal = "wal"
    self.socket_path = self.primary ? PRIMARY_SOCKET_PATH : REPLICA_SOCKET_PATH
    self.socket = UNIXServer.new(socket_path)
    self.request_handler = RequestHandler.new(self, wal)
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
    File.unlink(socket.path)
  end

  def primary?
    primary == true
  end
end
