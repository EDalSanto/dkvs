# frozen_string_literal: true

require "rspec"
require "json"
require_relative "../lib/file_store"

TEST_PATH = "/tmp/test_store"

describe FileStore do
  after(:each) { File.delete(TEST_PATH) }

  describe "#read" do
    it "returns parsed JSON" do
      data = { "a" => 42 }
      File.write(TEST_PATH, data.to_json)
      file_store = described_class.new(path: TEST_PATH)
      expect(file_store.read).to eq(data)
    end

    it "returns parsed JSON even on multiple calls" do
      data = { "a" => 42 }
      File.write(TEST_PATH, data.to_json)
      file_store = described_class.new(path: TEST_PATH)
      expect(file_store.read).to eq(data)
      expect(file_store.read).to eq(data)
    end
  end

  describe "#write" do
    it "overwrites file with data" do
      old_data = { "a" => 42 }
      File.write(TEST_PATH, old_data.to_json)
      new_data = { "b" => 10 }
      file_store = described_class.new(path: TEST_PATH)
      expect { file_store.write(new_data) }.to change {
        File.read(TEST_PATH)
      }.from(old_data.to_json).to(new_data.to_json)
    end
  end
end
