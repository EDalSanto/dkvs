# frozen_string_literal: true

require "rspec"
require "json"
require_relative "../lib/file_store"
require_relative "../lib/hash_map_pb"
require "spec_helper"

describe FileStore do
  after(:each) { File.delete(STORE_TEST_PATH) }

  describe "#read" do
    it "returns parsed protobuf" do
      # setup
      data = { "a" => "42" }
      hash_map_pb = Dkvs::HashMap.new(pairs: data)
      serialized = Dkvs::HashMap.encode(hash_map_pb)
      File.write(STORE_TEST_PATH, serialized)

      file_store = described_class.new(path: STORE_TEST_PATH)
      expect(file_store.read).to eq(data)
    end

    it "returns parsed JSON even on multiple calls" do
      # setup
      data = { "a" => "42" }
      hash_map_pb = Dkvs::HashMap.new(pairs: data)
      serialized = Dkvs::HashMap.encode(hash_map_pb)
      File.write(STORE_TEST_PATH, serialized)

      file_store = described_class.new(path: STORE_TEST_PATH)
      expect(file_store.read).to eq(data)
      expect(file_store.read).to eq(data)
    end
  end

  describe "#write" do
    it "overwrites file with new data" do
      # setup
      old_data = { "a" => "42" }
      hash_map_pb = Dkvs::HashMap.new(pairs: old_data)
      old_serialized = Dkvs::HashMap.encode(hash_map_pb)
      File.write(STORE_TEST_PATH, old_serialized)
      # new
      new_data = { "b" => "10" }
      hash_map_pb = Dkvs::HashMap.new(pairs: new_data)
      new_serialized = Dkvs::HashMap.encode(hash_map_pb)
      file_store = described_class.new(path: STORE_TEST_PATH)
      expect { file_store.write(new_data) }.to change {
        File.read(STORE_TEST_PATH)
      }.from(old_serialized).to(new_serialized)
    end
  end
end
