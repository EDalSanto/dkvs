# frozen_string_literal: true

require "socket"
require "readline"
require "pry"

# make connection to server process, sends request and receives response
class Client
  attr_accessor :socket
  DEFAULT_SOCKET_NAME = "/tmp/dkvs.sock"

  def initialize(socket_name: DEFAULT_SOCKET_NAME)
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
