<a href="https://rubygems.org/gems/low_loop" title="Install gem"><img src="https://badge.fury.io/rb/low_loop.svg" alt="Gem version" height="18"></a>

# LowLoop [UNRELEASED]

LowLoop is an asynchronous event-driven server that ties into [LowEvent](https://github.com/low-rb/low_event) to create and send events from the request layer right through to the application and data layers. Finally you can see and track events through every step of your application. Simply add `observe 'users/:id'` to a [LowNode](https://github.com/low-rb/low_node) and now it will be called every time a request is made to this route.
