# frozen_string_literal: true

require "rspec"
require "spec_helper"
require_relative "../lib/client"

describe "Client/Server Interaction" do
  it "can exchange messages" do
    server = TestServer.new
    # listen to connections in different thread
    thread = Thread.new do
      server.accept_connections do |client|
        msg = client.gets
        expect(msg).to_not be_nil
        client.puts("handled client request")
      end
    end
    # connect with client
    client_one = Client.new(socket_name: server.socket_path)
    response = client_one.send("msg from client one")
    expect(response).to_not be_nil
    # connect with another client
    client_two = Client.new(socket_name: server.socket_path)
    response = client_two.send("msg from client two")
    expect(response).to_not be_nil
    # kill thread waiting for connections
    thread.kill
    # clean up
    server.shut_down
  end
end
