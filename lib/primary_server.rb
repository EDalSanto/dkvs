# frozen_string_literal: true

require_relative "server"

class PrimaryServer < Server
  def primary
    true
  end

  private

  def socket_path
    "/tmp/dkvs-primary-server.sock"
  end

  def file_path
    "/tmp/dkvs-store"
  end
end
