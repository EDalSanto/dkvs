# frozen_string_literal: true

require "pry"

# Handle requests made to server from clients
class RequestHandler
  attr_reader :file_store

  def initialize(file_store)
    @file_store = file_store
  end

  def handle(request)
    memory_store = file_store.read
    command, args = request.split
    case command
    when "GET"
      key = args
      memory_store[key]
    when "SET"
      key, value = args.split("=")
      memory_store[key] = value
      # flush that overwrites file with memory store
      # maybe can flush only when server closes or periodically to reduce I/Os
      file_store.write(memory_store)
      memory_store[key]
    end
  end
end
