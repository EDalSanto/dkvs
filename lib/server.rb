#!/Users/Me/.rbenv/versions/2.5.3/bin/ruby
# frozen_string_literal: true

require "socket"
require_relative "request_handler"
require "pry"

class Server
  STORE_FILE_NAME = "/tmp/store"
  SOCKET_NAME = "/tmp/dkvs.sock"

  def run
    begin # ensure socket free
      File.unlink(SOCKET_NAME)
    rescue Errno::ENOENT
      puts "socket not present, skipping unlink"
    end
    # open file for appends / reads
    file_store = File.open(STORE_FILE_NAME, "a+")
    if file_store.size.zero?
      # init file with serialized content
      init_data = Marshal.dump({})
      file_store.write(init_data)
      file_store.rewind
    end
    # accept connections to clients
    server = UNIXServer.new(SOCKET_NAME)
    while true
      # handle multiple client requests
      Thread.start(server.accept) do |client|
        request = client.gets.chomp
        p "request: #{request}"
        result = RequestHandler.call(request, file_store)
        client.puts(result)
        client.close
      end
    end
    # clean up
    server.close
  end
end

Server.new.run
