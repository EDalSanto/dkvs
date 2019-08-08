# frozen_string_literal: true

# helper methods for command line "UI"
class Display
  def client_welcome
    puts "dkvs client initiated"
    usage
  end

  def server_boot_up
    puts "Running Server..."
    puts "Accepting Client Requests"
    puts "------------------------"
  end

  def invalid_input
    puts "invalid input"
    usage
  end

  def usage
    puts "usage GET: GET key"
    puts "usage SET: SET key=value"
  end

  def line_segment
    puts "------------------------"
  end

  def key_value(key, value)
    puts "#{key}: \"#{value}\""
  end

  def new_line
    ""
  end

  def shut_down
    "Shutting down..."
  end
end
