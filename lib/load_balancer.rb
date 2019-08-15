# frozen_string_literal: true

require "socket"
require_relative "server"

# accepts connections from clients for access to one of managed servers
# distributes requests to a server using round robin
class LoadBalancer
  LISTENING_SOCKET_PATH = "/tmp/dkvs_lb.sock"
  attr_accessor :servers, :primary, :replica, :listening_socket

  def initialize(servers: [])
    self.primary = UNIXSocket.new("/tmp/dkvs-primary-server.sock")
    self.replica = UNIXSocket.new("/tmp/dkvs-replica-server.sock")
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
    promote_primary if !primary_available?

    if write?(request)
      return "Uh Oh, no primary" if primary.nil?
      send(primary, request)
    else
      send(random_server, request)
    end
  end

  def shut_down
    File.unlink(listening_socket.path)
  end

  private

  def promote_primary
    self.primary = replica
  end

  def primary_available?
    begin
      primary.puts "PING"
      primary.gets # nada
    rescue Errno::EPIPE
      false
    else
      true
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
