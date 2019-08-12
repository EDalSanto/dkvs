# frozen_string_literal: true

require_relative "./hash_map_pb"
require "pry"

# handles details of maintaining persistent data
class FileStore
  attr_accessor :file, :path
  PRIMARY_PATH = "/tmp/dkvs_store"
  REPLICA_PATH = "/tmp/dkvs_replica_store"

  def initialize(primary, path: PRIMARY_PATH)
    self.path = primary ? PRIMARY_PATH : REPLICA_PATH
    # get replica up to date to last disk
    if !primary
      File.write(self.path, File.read(PRIMARY_PATH))
    end
    self.file = File.open(self.path, "a+")
    init_file if file.size.zero?
  end

  def read
    output = decode(file.read)
    file.rewind
    output["pairs"].to_h
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

  # TODO: extract details about Dkvs
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
