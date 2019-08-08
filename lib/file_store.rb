# frozen_string_literal: true

require "hash_map_pb"

# handles details of maintaining persistent data
class FileStore
  attr_accessor :file, :path
  DEFAULT_PATH = "/tmp/dkvs_store"

  def initialize(path: DEFAULT_PATH)
    self.path = path
    self.file = File.open(path, "a+")
    init_file if file.size.zero?
  end

  def read
    output = decode(file.read)
    file.rewind
    output["pairs"]
  end

  def write(data)
    File.write(file, encode(pb_data(pairs: data)))
    file.rewind
  end

  def delete
    File.delete(path)
  end

  private

  def init_file
    file.write(encode(init_data))
    file.rewind
  end

  def init_data
    pb_data(pairs: {})
  end

  def pb_data(pairs:)
    Dkvs::HashMap.new(pairs: pairs)
  end

  def encode(pb_data)
    Dkvs::HashMap.encode(pb_data)
  end

  def decode(encoded_data)
    Dkvs::HashMap.decode(encoded_data)
  end
end
