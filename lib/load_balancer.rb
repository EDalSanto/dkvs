# frozen_string_literal: true

require "socket"
require_relative "server"

# accepts connections from clients for access to one of managed servers
# distributes requests to a server using round robin
class LoadBalancer
  LISTENING_SOCKET_PATH = "/tmp/dkvs_lb.sock"
  attr_accessor :servers, :listening_socket

  def initialize(servers: [])
    self.servers = servers
    self.listening_socket = UNIXServer.new(LISTENING_SOCKET_PATH)
  end

  def connect_to_primary
    # primary = Server.new(primary: true)
    # open socket to expected running process
    primary = UNIXSocket.new("/tmp/dkvs-primary.sock")
    servers.push(primary)
  end

  def connect_to_replica
    replica = UNIXSocket.new("/tmp/dkvs-replica.sock")
    servers.push(replica)
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

  def send(server, request)
    server.puts(request)
    server.gets.chomp
  end

  def random_server
    servers.sample
  end

  def primary
    servers.first
  end

  def write?(request)
    request.match(/SET/i)
  end
end
