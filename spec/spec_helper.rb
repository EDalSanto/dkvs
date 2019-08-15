# frozen_string_literal: true

STORE_TEST_PATH = "/tmp/test_store"
require_relative "../lib/server"

class TestServer < Server
  def primary
    false
  end

  def file_path
    "/tmp/dkvs-test-store"
  end

  def socket_path
    "/tmp/dkvs-test.sock"
  end
end
