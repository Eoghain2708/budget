class Category
  attr_accessor :id
  attr_accessor :title, :colour

  ALLOWED_COLOURS = ["red", "bright_red", "cyan", "bright_cyan", "green", "bright_green", "magenta", "bright_magenta", "blue"].freeze

  # @param title - [String]
  # @param colour - [String]
  # @example - 
  # category = Category.new(title: "groceries", colour: "bright_cyan")
  # @return [Category]
  def initialize(id: nil, title:, colour:)
    raise ArgumentError, "Invalid name" unless title && title.length > 1
    raise ArgumentError, "Invalid colour" unless ALLOWED_COLOURS.include?(colour)
    @id = id
    @title = title
    @colour = colour
  end
end