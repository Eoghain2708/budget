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
    end
  end
end