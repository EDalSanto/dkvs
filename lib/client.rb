# frozen_string_literal: true

require "socket"
require "readline"
require "pry"

class Client
  attr_accessor :socket
  SOCKET_NAME = "/tmp/dkvs.sock"

  def initialize
    self.socket = UNIXSocket.new(SOCKET_NAME)
  end

  # read input from user, send over socket, get response
  def run
    loop do
      display_line_segment
      request = Readline.readline("request: ", true).chomp
      break if request == "EXIT"

      socket.puts(request)
      # get response from server
      response = socket.recv(20).chomp
      p "response: #{response}"
    end
  end

  def shutdown
    socket.close
  end

  private

  def display_welcome
    puts "dkvs client initiated"
    display_usage
  end

  def display_invalid_input
    puts "invalid input"
    display_usage
  end

  def display_usage
    puts "usage GET: GET key"
    puts "usage SET: SET key=value"
  end

  def display_line_segment
    puts "------------------------"
  end
end

client = Client.new
Signal.trap("INT") {
  client.shutdown
  exit
}
client.run
