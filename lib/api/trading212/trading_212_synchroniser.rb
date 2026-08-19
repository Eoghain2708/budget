require_relative "../common/investment_synchroniser"
require_relative "../trading212/trading_212_api"
require "date"
require_relative "../../cli/commands/helpers"
require_relative "../../cli/prompts"
require "pastel"
require "tty-prompt"
require "irb"

module Budget
  module API
    class Trading212Synchroniser < Budget::API::InvestmentSynchroniser
      # @param bs [BudgetService]
      # @param client [Budget::API::Trading212]
      def initialize(bs, client)
        super(:trading212, bs)
        @client = client
        @history = @client.orders
        @helper = Commands::Helpers.new(bs: @bs, transaction_prompts: Prompts::TransactionPrompts.new(TTY::Prompt.new, Pastel.new))
      end

      def synchronise
        unprocessed = find_and_parse_unprocessed
        unless unprocessed.size > 0
          puts "Trading212 transactions up to date!"
          return
        end
        ignored = @helper.find_transactions_to_ignore(unprocessed)
        res = unprocessed - ignored
        return unless res.size > 0

        res.each do |transaction|
          @bs.add_transaction_with_object(transaction)
          puts "Transaction created! Amount: #{transaction.price} | #{transaction.merchant} | #{transaction.nature}"
        end
      end

      def find_and_parse_unprocessed
         puts "Choose a category for payments."
         category = @helper.get_category
         unprocessed = []
         @history["items"].each do |order|
          order_data = order["order"]
          date = Date.parse(order_data["createdAt"])
          nature = order_data["side"] == "BUY" ? :investment : :income
          found = @bs.find_transactions_by_attrs(
            on: date, 
            nature: nature,
            price: order_data["value"],
            merchant: order_data["ticker"]
          )

          if found.empty?
            unprocessed << Transaction.new(
              date: date,
              nature: nature,
              merchant: order_data["ticker"],
              category: category,
              price: order_data["value"]
            )
          end
        end
        return unprocessed
      end
    end
  end
end
