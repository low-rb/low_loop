# frozen_string_literal: true

require 'async'

module Low
  class Loop
    PORT = ENV.fetch('PORT', 4133)
    HOST = ENV.fetch('HOST', '127.0.0.1').freeze

    class << self
      def start
        server = TCPServer.new(HOST, PORT)
        puts "Server@#{HOST}:#{PORT}"
        # server.listen(10)

        Fiber.set_scheduler(Async::Scheduler.new)

        Fiber.schedule do
          loop do
            socket = server.accept

            Fiber.schedule do
              require 'pry'; binding.pry

              # TODO: Use protocol-http where possible, can it parse this request?
              # request = RequestParser.call(socket)
              # status, headers, body = app.call(request)
              # puts status, headers, body

              # NEXT:
              #  The goal here is to create RequestEvents, have the EventManager store subscriptions to those events (overvable/observer).
              #  Have a RainRouter in between LowLoop and the LowNodes that are subscribed to routes for the RainRouter.
              #  Good luck

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
  end
end
