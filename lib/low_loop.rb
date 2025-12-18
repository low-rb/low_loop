# frozen_string_literal: true

require 'async'
require 'socket'
require 'low_type'
require 'low_event'
require 'observers'

require_relative 'request_parser'

class LowLoop
  extend Observers
  observable

  PORT = ENV.fetch('PORT', 4133)
  HOST = ENV.fetch('HOST', '127.0.0.1').freeze

  def start
    server = TCPServer.new(HOST, PORT)
    puts "Server@#{HOST}:#{PORT}"
    # server.listen(10)

    require 'pry'; binding.pry

    Fiber.set_scheduler(Async::Scheduler.new)

    Fiber.schedule do
      loop do
        socket = server.accept

        Fiber.schedule do
          request = Low::RequestParser.parse(socket:, host: HOST, port: PORT)

          # NEXT:
          #  The goal here is to create RequestEvents, have the EventManager subscribe to those events (observable/observer/observe).
          #  Have a RainRouter in between LowLoop and the LowNodes that are subscribed to routes for the RainRouter.
          #  Good luck

          request_response = LowLoop.take Low::RequestEvent.new(request:)

          # HttpResponder.call(socket, status, headers, body)
        rescue => e
          puts e.message
        ensure
          socket&.close
        end
      end
    end
  end
end
