# frozen_string_literal: true

# handles details of maintaining persistent data
class FileStore
  attr_accessor :file, :path
  DEFAULT_PATH = "/tmp/dkvs_store"

  def initialize(path: DEFUALT_PATH)
    self.path = path
    self.file = File.open(path, "a+")
    init_file if file.size.zero?
  end

  def read
    output = JSON.parse(file.read)
    file.rewind
    output
  end

  def write(data)
    File.write(file, data.to_json)
    file.rewind
  end

  def delete
    File.delete(path)
  end

  private

  def init_file
    init_data = {}.to_json
    file.write(init_data)
    file.rewind
  end
end
