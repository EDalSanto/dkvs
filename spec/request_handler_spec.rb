# frozen_string_literal: true

require "rspec"
require_relative "../lib/request_handler"

describe RequestHandler do
  describe ".call" do
    context "GET" do
      it "returns nil when key not present in file" do
        request = "GET foo"
        file_store = File.new("test_file", "w+")

        response = described_class.call(request, file_store)
        expect(response).to be_nil
        # clean up TODO: stub
        File.delete(file_store)
      end

      it "returns value when key present in file" do

      end
    end

    context "SET" do
      it "updates the key in the file" do

      end
    end
  end
end
