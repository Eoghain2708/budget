module Budget
  module Errors
    class InvalidBrokerError < StandardError 
      ALLOWED_BROKERS = [:trading212]
      def initialize(message="Invalid broker")
        super(message)
      end

      def self.check_and_throw(broker)
        raise new unless ALLOWED_BROKERS.include? broker
      end
    end
  end
end