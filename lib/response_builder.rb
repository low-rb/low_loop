# frozen_string_literal: true

module Low
  class ResponseBuilder
    PORT = ENV.fetch('PORT', 4133)
    HOST = ENV.fetch('HOST', '127.0.0.1').freeze

    class << self
      # TODO: Use Async wherever we can where it doesn't have "Task" requirement.
      def respond(socket:, response:)
        socket.puts "#{response.version} #{response.status}\r\n"
        socket.puts PORT.nil? ? "Host: #{HOST}\r\n" : "Host: #{HOST}:#{PORT}\r\n"
        socket.puts "\r\n"
        socket.puts(response.body.read)
        socket.close
      end
    end
  end
end
