# frozen_string_literal: true

require "socket"
require_relative "server"

# accepts connections from clients for access to one of managed servers
# distributes requests to a server using round robin
class LoadBalancer
  LISTENING_SOCKET_PATH = "/tmp/dkvs_lb.sock"
  PRIMARY_SERVER_SOCKET_PATH = "/tmp/dkvs-primary-server.sock"
  REPLICA_SERVER_SOCKET_PATH = "/tmp/dkvs-replica-server.sock"
  attr_accessor :servers, :primary, :replica, :listening_socket

  def initialize(servers: [])
    self.primary = UNIXSocket.new(PRIMARY_SERVER_SOCKET_PATH)
    self.replica = UNIXSocket.new(REPLICA_SERVER_SOCKET_PATH)
    self.servers = [ primary, replica ]
    self.listening_socket = UNIXServer.new(LISTENING_SOCKET_PATH)
  end

  # accept connections from client processes
  def accept_connections
    loop do
      # socket open for clients
      # handle multiple client requests
      Thread.start(listening_socket.accept) do |client|
        yield(client)
        client.close
      end
    end
  end

  # send server request and get back response
  def distribute(request)
    promote_replica_to_primary if primary_not_available?
    return "Uh Oh, no primary" if primary.nil?

    if write?(request)
      send(primary, request)
    else
      send(random_server, request)
    end
  end

  def shut_down
    File.unlink(listening_socket.path)
  end

  private

  def promote_replica_to_primary
    # remove primary
    servers.shift
    self.primary = servers.first
  end

  def primary_not_available?
    begin
      primary.puts "PING"
      primary.gets # nada
    rescue Errno::EPIPE
      true
    else
      false
    end
  end

  def send(server, request)
    server.puts(request)
    server.gets.chomp
  end

  def random_server
    servers.sample
  end

  def write?(request)
    request.match(/SET/i)
  end
end
