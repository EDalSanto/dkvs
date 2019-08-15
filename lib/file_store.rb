# frozen_string_literal: true

require_relative "./hash_map_pb"

# handles details of maintaining persistent data
class FileStore
  PRIMARY_PATH = "/tmp/dkvs-store"
  attr_accessor :file, :path

  def initialize(path:)
    self.path = path
    self.file = File.open(self.path, "a+")
    init_file if file.size.zero?
    update_to_latest_primary
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

  def update_to_latest_primary
    File.write(path, File.read(PRIMARY_PATH))
  end

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
