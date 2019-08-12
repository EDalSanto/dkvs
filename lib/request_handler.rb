# frozen_string_literal: true

require "pry"

# Handle requests made to server from clients
class RequestHandler
  COMMAND_ARGS_DELIMETER = /\s+/.freeze
  KEY_VALUE_PAIRS_DELIMETER = /\s*&\s*/.freeze
  KEY_VALUE_DELIMETER = /\s*=\s*/.freeze
  attr_reader :file_store, :wal

  def initialize(file_store, wal)
    @file_store = file_store
    @wal = wal
  end

  def handle(request)
    memory_store = file_store.read
    # String#split takes 2nd argument which limit
    command, args = request.split(COMMAND_ARGS_DELIMETER, 2)
    case command.upcase
    when "GET"
      key = args
      memory_store[key]
    when "SET"
      key_value_pairs = args.split(KEY_VALUE_PAIRS_DELIMETER)
      key_value_pairs.each do |key_value_pair|
        key, value = key_value_pair.split(KEY_VALUE_DELIMETER)
        memory_store[key] = value
        # add to WAL
        #wal.add(key, val)
      end
      # flush that overwrites file with memory store
      # wal.flush! if ready_to_flush?
      # maybe can flush only when server closes or periodically to reduce I/Os
      file_store.write(memory_store)
      memory_store[key]
      true
    end
  end
end
