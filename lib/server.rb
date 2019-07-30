# frozen_string_literal: true

require "socket"
require_relative "request_handler"
require "pry"

# open listening socket, manage file store, delegate commands
class Server
  attr_accessor :file_store, :socket
  STORE_FILE_NAME = "/tmp/store"
  SOCKET_NAME = "/tmp/dkvs.sock"

  def initialize
    # open file for appends / reads
    self.file_store = File.open(STORE_FILE_NAME, "a+")
    if file_store.size.zero?
      # init file with serialized content
      init_data = {}.to_json
      file_store.write(init_data)
      file_store.rewind
    end
    # open listening socket
    self.socket = UNIXServer.new(SOCKET_NAME)
  end

  def run
    loop do
      # handle multiple client requests
      Thread.start(socket.accept) do |client|
        loop do
          request = client.gets.chomp
          break if request.length.zero?

          p "request: #{request}"
          result = RequestHandler.call(request, file_store)
          client.puts(result)
        end

        client.close
      end
    end

    shut_down
  end

  def shut_down
    File.unlink(SOCKET_NAME)
  end
end

# TODO: move to executable
server = Server.new
# Trap ^C
Signal.trap("INT") {
  server.shut_down
  exit
}
server.run
