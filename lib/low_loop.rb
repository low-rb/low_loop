# frozen_string_literal: true

require 'async'
require 'socket'
require 'low_type'
require 'low_event'
require 'observers'

require_relative 'request_parser'
require_relative 'response_builder'

module Low
  class Loop
    extend Observers
    observable

    PORT = ENV.fetch('PORT', 4133)
    HOST = ENV.fetch('HOST', '127.0.0.1').freeze

    def start
      server = TCPServer.new(HOST, PORT)
      puts "Server@#{HOST}:#{PORT}"
      # server.listen(10)

      Fiber.set_scheduler(Async::Scheduler.new)

      Fiber.schedule do
        loop do
          socket = server.accept

          Fiber.schedule do
            request = RequestParser.parse(socket:, host: HOST, port: PORT)

            # NEXT:
            #  Have a RainRouter in between LowLoop and the LowNodes that are subscribed to routes for the RainRouter.

            response_event = LowLoop.take RequestEvent.new(request:)

            ResponseBuilder.respond(socket:, response: response_event.response)
          rescue StandardError => e
            puts e.message
          ensure
            socket&.close
          end
        end
      end
    end
  end
end

LowLoop = Low::Loop
