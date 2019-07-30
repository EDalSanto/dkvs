# frozen_string_literal: true

require "socket"
require "pry"
require_relative "request_handler"
require_relative "file_store"

# handle client requests
class Server
  attr_accessor :file_store, :socket, :request_handler
  SOCKET_NAME = "/tmp/dkvs.sock"

  def initialize
    self.file_store = FileStore.new
    self.socket = UNIXServer.new(SOCKET_NAME)
    self.request_handler = RequestHandler.new(file_store)
  end

  def run
    boot_up

    loop do
      # handle multiple client requests
      Thread.start(socket.accept) do |client|
        loop do
          request = client.gets&.chomp
          break if request.nil?

          puts "request: #{request}"
          response = request_handler.handle(request)
          puts "response: \"#{response}\""
          client.puts(response)
          puts "-----------------------"
        end

        client.close
      end
    end

    shut_down
  end

  def shut_down
    File.unlink(SOCKET_NAME)
  end

  private

  def boot_up
    puts "Running Server..."
    puts "Accepting Client Requests"
    puts "------------------------"
  end
end

# TODO: move to executable
server = Server.new
# Trap ^C
Signal.trap("INT") {
  server.shut_down
  puts ""
  puts "-------------------"
  puts "Shutting down server"
  exit
}
server.run
