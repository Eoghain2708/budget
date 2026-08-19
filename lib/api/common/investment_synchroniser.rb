require_relative "../../errors/invalid_broker_error"

module Budget
  module API
    class InvestmentSynchroniser

      # @param broker [Symbol]
      # @param bs [BudgetService]
      def initialize(broker, bs)
        Budget::Errors::InvalidBrokerError.check_and_throw(broker)
        @broker = broker
        @bs = bs
      end

      def synchronise
        raise NotImplementedError, ":synchronise must be implemented."
      end

      def find_and_parse_unprocessed
        raise NotImplementedError, ":find_and_parse_unprocessed must be implemented"
      end
    end
  end
end