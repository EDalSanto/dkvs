# frozen_string_literal: true

require "socket"
require "readline"
require "pry"

# make connection to server process, sends request and receives response
class Client
  attr_accessor :socket
  SOCKET_NAME = "/tmp/dkvs.sock"

  def initialize
    self.socket = UNIXSocket.new(SOCKET_NAME)
  end

  def send(request)
    socket.puts(request)
    socket.gets.chomp
  end

  def shutdown
    socket.close
  end
end
