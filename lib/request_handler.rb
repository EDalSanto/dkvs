# frozen_string_literal: true

require "pry"

# Handle requests made to server from clients
class RequestHandler
  def self.call(request, file_store)
    # load data into memory
    json_file_contents = file_store.read
    file_store.rewind
    memory_store = JSON.parse(json_file_contents)
    # process command
    command, args = request.split
    case command
    when "GET"
      # search for in-memory buffer than file
      key = args
      memory_store[key]
    when "SET"
      # try to load key from buffer than file
      key, value = args.split("=")
      memory_store[key] = value
      # flush that overwrites file with memory store
      File.write(file_store, memory_store.to_json)
      file_store.rewind
      # updated value
      memory_store[key]
    end
  end
end
