require 'deepstream/constants'

module Deepstream
  class EventHandler
    def initialize(client)
      @client = client
      @callbacks = {}
    end

    def on(event, &block)
      @callbacks[event] = block
      @client.send(TOPIC::EVENT, ACTION::SUBSCRIBE, event)
    end

    def on_message(message)
      case message.action
      when ACTION::ACK then nil
      when ACTION::EVENT then fire_event_callback(message)
      else @client.error(message)
      end
    end

    def emit(*args)
      @client.send(TOPIC::EVENT, ACTION::EVENT, args)
    end

    def unsubscribe(event)
      @callbacks.delete(event)
      @client.send(TOPIC::EVENT, ACTION::UNSUBSCRIBE, event)
    end

    def fire_event_callback(message)
      event, *args = message.data
      Celluloid::Future.new { @callbacks[event].(args) }
    end
  end
end
