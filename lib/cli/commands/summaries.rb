require_relative 'commands'

module Commands
  module Summaries
    PROMPT = TTY::Prompt.new
    PASTEL = Pastel.new
    class WeeklySummary
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
      end

      # @param date [Date]
      # @param options [Hash]
      def run(date, options = nil)
        return {} unless date

        summary = @rs.weekly_summary(date)
        last_week_summary = @rs.weekly_summary(date - 7)
        SummaryFormatter.new(summary, last_week_summary, period: :week).format(options: options)
      end
    end

    class MonthlySummary
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
      end

      # @param date [Date]
      # @param options [Hash]
      def run(date, options = nil)
        return {} unless date

        summary = @rs.monthly_summary(date)
        last_month_summary = @rs.monthly_summary(date << 1)
        SummaryFormatter.new(summary, last_month_summary, period: :month).format(options: options)
      end
    end

    class DailySummary
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
      end

      # @param date [Date]
      # @param options [Hash]
      def run(date, options = nil)
        return {} unless date

        summary = @rs.daily_summary(date)
        yesterday_summary = @rs.daily_summary(date - 1)
        SummaryFormatter.new(summary, yesterday_summary, period: :day).format(options: options)
      end
    end

    class YearlySummary
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
      end

      # @param date [Date]
      # @param options [Hash]
      def run(date, options = nil)
        return {} unless date

        summary = @rs.yearly_summary(date)
        yesterday_summary = @rs.yearly_summary(date << 12)
        SummaryFormatter.new(summary, yesterday_summary, period: :year).format(options: options)
      end
    end
  end
end
