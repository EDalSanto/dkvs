# frozen_string_literal: true

require "socket"
require "readline"
require "pry"

# make connection to load balancer process, sends request and receives response
class Client
  attr_accessor :socket
  LB_SOCKET_PATH = "/tmp/dkvs_lb.sock"

  def initialize(socket_name: LB_SOCKET_PATH)
    self.socket = UNIXSocket.new(socket_name)
  end

  def send(request)
    socket.puts(request)
    socket.gets.chomp
  end

  def shut_down
    socket.close
  end
end
