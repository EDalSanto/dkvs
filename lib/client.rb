# frozen_string_literal: true

require "socket"
require "readline"

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

SOCKET_NAME = "/tmp/dkvs.sock"

display_welcome
# opens socket to server
client = UNIXSocket.new(SOCKET_NAME)
# read input from user, send over socket, get response
while true
  display_line_segment
  request = Readline.readline("request: ", true).chomp
  break if request == "EXIT"
  client.puts(request)
  # get response from server
  response = client.recv(20).chomp
  p "response: #{response}"
end
