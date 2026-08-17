require "json"
require "tty-table"
require "pastel"
require_relative "../../helpers/formatting_helper"
require_relative "../../errors/trading_212_error"


module Budget
  module API
    module Trading212Formatter
      PASTEL = Pastel.new

      # @param summary [Hash<String, Object>]
      def self.format_summary(summary)

        validate(summary)

        currency = summary&.dig("currency")
        in_wallet = summary&.dig("cash", "availableToTrade")
        portfolio_value = summary&.dig("investments", "currentValue")
        total_invested = summary&.dig("investments", "totalCost")
        profit = summary&.dig("investments", "unrealizedProfitLoss")

        table = TTY::Table.new(
        header: ["Currency", "Cash", "Invested", "Value", "P/L"],
        rows: [[
          currency,
          FormattingHelper.colourise_money(in_wallet),
          FormattingHelper.colourise_money(total_invested),
          FormattingHelper.colourise_money(portfolio_value),
          FormattingHelper.colourise_money(profit, signed: true)
          ]]
        )

        puts PASTEL.bold.bright_yellow table.render(:unicode)
      end

      # @param positions [Array<Hash<String, Object>>]
      # @return [Void]
      def self.format_positions(positions)
        validate(positions)
        rows = []
        positions.each do |position|
          currency = PASTEL.white.bold position.dig("walletImpact", "currency")
          name = PASTEL.bold.cyan "#{position.dig("instrument", "ticker")} (#{position.dig("instrument", "name")})"
          number_shares = PASTEL.bold position.dig("quantity").round(2)
          average_pps = PASTEL.bold position.dig("averagePricePaid").round(2)
          current_pps = PASTEL.bold position.dig("currentPrice").round(2)
          
          total_invested = (position.dig("walletImpact", "totalCost"))
          formatted_total_invested = FormattingHelper.colourise_money_negative(total_invested)

          current_value = (position.dig("walletImpact", "currentValue"))
          formatted_current_value = FormattingHelper.colourise_position(total_invested, current_value)

          profit_loss = FormattingHelper.colourise_money(position.dig("walletImpact", "unrealizedProfitLoss"), signed: true, symbol: false)
          rows << [
            currency, name, number_shares, average_pps, current_pps,
            formatted_total_invested, formatted_current_value, profit_loss
          ]
        end

        table = TTY::Table.new(
          header: ["Currency", "Name", "Shares", "Avg. Share", "Curr. Share", "Invested", "Value", "P/L"],
          rows: rows
        )
        puts PASTEL.bold.bright_yellow table.render(:unicode)
      end


      private
      def self.validate(summary)
        if summary.empty? 
          raise Budget::Errors::Trading212.new
        end
      end
   
    end
  end
end