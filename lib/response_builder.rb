# frozen_string_literal: true

module Low
  class ResponseBuilder
    class << self
      # TODO: Use Async wherever we can where it doesn't have "Task" requirement.
      def respond(config:, socket:, response:)
        socket.puts "#{response.version} #{response.status}\r\n"
        socket.puts config.port.nil? ? "Host: #{config.host}\r\n" : "Host: #{config.host}:#{config.port}\r\n"
        socket.puts "\r\n"
        socket.puts(response.body.read)
        socket.close
      end
    end
  end
end
