# frozen_string_literal: true

class ReplicaServer < Server
  def primary
    false
  end

  private

  def socket_path
    "/tmp/dkvs-replica-server.sock"
  end

  def file_path
    "/tmp/dkvs-replica-store"
  end
end
