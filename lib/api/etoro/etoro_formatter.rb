require "tty-table"
require "pastel"
require_relative "../../../lib/helpers/formatting_helper"

module Budget
  module API
    module EToroFormatter
      PASTEL = Pastel.new
      # @param data [Hash<String, Object>]
      def self.format_positions(data)
        info = relevant_position_data(data)
        info.sort_by! { |i| -i[:total_pnl]}
        headers = ["  Currency  ", "  Stock  ", "  Positions  ", "  Inv.  ", "  Val.  ", "  P/L  "]
        rows = info.map do |i|
          [
            PASTEL.bold(i[:currency]), 
            PASTEL.bold(i[:stock]), 
            PASTEL.bold(i[:positions]), 
            FormattingHelper.colourise_money(i[:total_invested].round(2)), 
            FormattingHelper.colourise_position(i[:total_invested], i[:now_worth].round(2)), 
            FormattingHelper.colourise_money(i[:total_pnl].round(2), signed: true)]
        end

        table = TTY::Table.new(
          header: headers,
          rows: rows
        )

        puts PASTEL.bright_yellow.bold table.render(:unicode)
      end



      private
      def self.relevant_position_data(data)
        result = []
        instruments = data["instruments"]
        instruments.each do |inst|
          stock = inst["symbol"]
          positions = inst["positions"]
          total_invested = 0
          now_worth = 0
          investments_per_stock = positions.size
          positions.each do |pos|
            total_invested += pos["openRate"] * pos["units"]
            now_worth += pos["currentRate"] * pos["units"]
          end
          result << {
            stock: stock,
            positions: investments_per_stock,
            total_invested: total_invested,
            now_worth: now_worth,
            total_pnl: now_worth - total_invested,
            currency: "USD"
          }
        end
        return result
      end
    end
  end
end