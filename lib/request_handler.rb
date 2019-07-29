# frozen_string_literal: true

require "pry"

# Handle requests made to server from clients
class RequestHandler
  def self.call(request, file_store)
    # load data into memory
    serialized_file_contents = file_store.read
    file_store.rewind
    memory_store = Marshal.load(serialized_file_contents)
    # process command
    command, args = request.split
    case command
    when "GET"
      # search for in-memory buffer than file
      key = args
      $stdout.print "output: #{memory_store[key].inspect}\n"
      memory_store[key]
    when "SET"
      # try to load key from buffer than file
      key, value = args.split("=")
      assignment = (memory_store[key] = value)
      if assignment
        puts "Stored successful!"
      else
        puts "Could not save #{request.inspect}"
      end
      # flush that overwrites file with memory store
      File.write(file_store, Marshal.dump(memory_store))
      file_store.rewind
      memory_store[key]
    end
  end
end
