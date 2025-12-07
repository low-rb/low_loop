module Low
  class RequestResponder
    class << self
      app = Proc.new do
        ['200', {'Content-Type' => 'text/html'}, ["Hello world! The time is #{Time.now}"]]
      end
    end
  end
end
