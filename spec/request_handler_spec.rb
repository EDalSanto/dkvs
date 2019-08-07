# frozen_string_literal: true

require "rspec"
require_relative "../lib/request_handler"
require_relative "../lib/file_store"

TEST_PATH = "/tmp/test_store"

describe RequestHandler do
  describe "#handle" do
    after(:each) { file_store.delete }
    # need test file
    let(:file_store) { FileStore.new(path: TEST_PATH) }
    let(:handler) { described_class.new(file_store) }

    context "GET" do
      it "returns nil when key not present in file store" do
        request = "GET foo"
        response = handler.handle(request)
        expect(response).to be_nil
      end

      it "returns value when key present in file store" do
        request = "GET foo"
        file_store.write(foo: 42)
        response = handler.handle(request)
        expect(response).to eq(42)
      end
    end

    context "SET" do
      it "updates the key in the file store" do
        request = "SET foo=42"
        handler.handle(request)
        memory_store = file_store.read
        expect(memory_store["foo"]).to eq("42")
      end

      it "sets multiples key/values" do
        request = "SET foo=42&bar=10"
        handler.handle(request)
        memory_store = file_store.read
        expect(memory_store["foo"]).to eq("42")
        expect(memory_store["bar"]).to eq("10")
      end
    end
  end
end
