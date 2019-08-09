# frozen_string_literal: true

require "rspec"
require "json"
require_relative "../lib/file_store"
require "spec_helper"

describe FileStore do
  after(:each) { File.delete(STORE_TEST_PATH) }

  describe "#read" do
    it "returns decoded data" do
      # setup
      file_store = described_class.new(path: STORE_TEST_PATH)
      data = { "a" => "42" }
      file_store.write(data)
      # assert
      expect(file_store.read).to eq(data)
    end

    it "returns decoded data even on multiple calls" do
      # setup
      file_store = described_class.new(path: STORE_TEST_PATH)
      data = { "a" => "42" }
      file_store.write(data)
      # assert
      expect(file_store.read).to eq(data)
      expect(file_store.read).to eq(data)
    end
  end

  describe "#write" do
    it "overwrites file with new data" do
      # setup
      file_store = described_class.new(path: STORE_TEST_PATH)
      old_data = { "a" => "42" }
      file_store.write(old_data)
      # new
      new_data = { "b" => "10" }
      expect { file_store.write(new_data) }.to change {
        file_store.read
      }.from(old_data).to(new_data)
    end
  end
end
