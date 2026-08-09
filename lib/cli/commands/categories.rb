require_relative 'commands'

module Commands
  module Categories
    PROMPT = TTY::Prompt.new
    PASTEL = Pastel.new
    class AddCategory
      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
        @category_prompts = Prompts::CategoryPrompts.new(PROMPT, PASTEL)
      end

      def run
        title = @category_prompts.get_title
        PROMPT.ok("Creating category #{title}")
        colour = @category_prompts.get_colour
        category = @bs.create_category(title: title, colour: colour)
        PROMPT.ok("Created category #{PASTEL.public_send(colour.to_sym, title)} successfully!")
        category
      end
    end

    class ShowCategories
      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
      end

      def run
        categories = @bs.get_all_categories
        categories.each do |cat|
          puts "#{PASTEL.bold 'ID:'} #{PASTEL.bold cat.id} | #{PASTEL.bold.public_send(cat.colour, cat.title)}"
        end
      end
    end

    class DeleteCategory
      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(bs: @bs, transaction_prompts: @transaction_prompts)
      end

      def run
        category = @helper.get_category
        @bs.delete_category(category.id)
      end
    end

    class EditCategory
      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
        @category_prompts = Prompts::CategoryPrompts.new(PROMPT, PASTEL)
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(bs: @bs, transaction_prompts: @transaction_prompts, category_prompts: @category_prompts)
      end

      def run
        category = @helper.get_category
        if @category_prompts.get_wants_to_change_title
          new_title = @category_prompts.get_title
          category.title = new_title
        end

        if @category_prompts.get_wants_to_change_colour
          new_colour = @category_prompts.get_colour
          category.colour = new_colour
        end

        @bs.edit_category(category, new_title: new_title, new_colour: new_colour)
      end
    end
  end
end
