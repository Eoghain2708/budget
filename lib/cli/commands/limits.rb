require_relative "commands"

module Commands
  module Limits
    PROMPT = TTY::Prompt.new
    PASTEL = Pastel.new
      class ViewLimits
        # @param ls [LimitService]
        # @param bs [BudgetService]
        # @param rs [ReportService]
        def initialize(bs, rs, ls)
          @bs = bs
          @rs = rs
          @ls = ls
        end

        def run(category: nil, merchant: nil, period: nil)
          period_type = period.to_sym if period
          category = @bs.find_category_by_title if category
          date = Date.today
          limits = @ls.find_by_attrs(category:, merchant:, period_type:)
          # sort in order of category => merchant (presuming category budgets are probably more important)
          limits.sort_by! { |limit| limit.type }
          if period_type
            summaries = [@rs.public_send("#{period_type}_summary", date)]
          else 
            summaries = [
            @rs.daily_summary(date),
            @rs.weekly_summary(date),
            @rs.monthly_summary(date),
            @rs.yearly_summary(date)
          ]
          end
          
          LimitFormatter.new.format(limits, summaries)
        end
      end
        
      class AddLimit
        # @param bs [BudgetService]
        # @param rs [ReportService]
        # @param ls [LimitService]
        # @param transactions [Prompts::TransactionPrompts]
        # @param limits [Prompts::LimitPrompts]
        # @param helper [Commands::Helpers]
        def initialize(bs, rs, ls)
          @bs = bs
          @rs = rs
          @ls = ls
          @transactions = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
          @limits = Prompts::LimitPrompts.new(PROMPT, PASTEL)
          @helper = Commands::Helpers.new(bs: bs, transaction_prompts: @transactions, rs: @rs, ls: @ls, limit_prompts: @limits)
        end

        def run(merchant: nil, category: nil, amount: nil, period_type: nil)
          category = @bs.find_category_by_title if category
          amount ||= @limits.get_amount
          period_type ||= @limits.get_period_type

          unless merchant || category
            res = @limits.get_category_or_merchant
            if res == :merchant
              merchant = @helper.choose_merchant
            else 
              category = @helper.get_category
            end
          end
          
          @ls.create_limit(
            category: category,
            merchant: merchant,
            amount: amount,
            period_type: period_type
          )
          puts PASTEL.bold "Limit for #{category ? PASTEL.public_send(category.colour, category.title) : merchant} created successfully! Amount: #{amount}, nature: #{period_type}"
        end
      end

      class DeleteLimit
        # @param ls [LimitService]
        def initialize(ls)
          @ls = ls
          @limit_prompts = Prompts::LimitPrompts.new(PROMPT, PASTEL)
          @general_prompts = Prompts::General.new(PROMPT)
          @helper = Commands::Helpers.new(ls: @ls, limit_prompts: @limit_prompts)
        end

        def run
          limit = @helper.choose_limit

          if @general_prompts.confirmed
            @ls.delete_limit(limit)
            puts PASTEL.bold("Limit for #{limit.category ? limit.category : limit.merchant} deleted successfully!")
            return
          end
          puts "Cancelled."
          return
        end
      end

      class EditLimit
        # @param bs [BudgetService]
        # @param rs [ReportService]
        # @param ls [LimitService]
        def initialize(bs, rs, ls)
          @bs = bs
          @rs = rs
          @ls = ls
          @limit_prompts = Prompts::LimitPrompts.new(PROMPT, PASTEL)
          @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
          @helper = Commands::Helpers.new(bs: bs, rs: rs, ls: ls, limit_prompts: @limit_prompts, transaction_prompts: @transaction_prompts)
        end

        def run
          limit = @helper.choose_limit
          changes = @limit_prompts.get_changes(limit)

          new_category = @helper.get_category if changes.include? "category"
          new_merchant = @helper.choose_merchant if changes.include? "merchant"
          new_period_type = @limit_prompts.get_period_type if changes.include? "period-type"
          new_amount = @limit_prompts.get_amount if changes.include? "amount"

          # print out changes
          puts PASTEL.bold.bright_yellow @helper.previous_and_new(limit.category.title, new_category.title, "Category") if new_category
          puts PASTEL.bold.cyan @helper.previous_and_new(limit.merchant, new_merchant, "Merchant") if new_merchant
          puts PASTEL.bold @helper.previous_and_new(limit.period_type, new_period_type, "Period") if new_period_type
          puts PASTEL.bold @helper.previous_and_new(limit.amount, new_amount, "Amount") if new_amount
          @ls.edit_limit(limit, new_category:, new_merchant:, new_period_type:, new_amount:)
          puts PASTEL.bold.bright_green "Edited successfully!"
        end
      end
  end
end