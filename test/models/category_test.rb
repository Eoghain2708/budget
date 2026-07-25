require_relative "../test_helper"

class CategoryTest < Minitest::Test
  def test_creates_category
    category = Category.new(
      id: 1,
      title: "Groceries",
      colour: "bright_green"
    )

    assert_equal 1, category.id
    assert_equal "Groceries", category.title
    assert_equal "bright_green", category.colour
  end

  def test_title_must_exist
    assert_raises(ArgumentError) do
      Category.new(
        title: nil,
        colour: "red"
      )
    end
  end

  def test_title_must_be_longer_than_one_character
    assert_raises(ArgumentError) do
      Category.new(
        title: "A",
        colour: "red"
      )
    end
  end

  def test_colour_must_be_valid
    assert_raises(ArgumentError) do
      Category.new(
        title: "Food",
        colour: "purple"
      )
    end
  end

  def test_categories_with_same_id_are_equal
    first = Category.new(
      id: 5,
      title: "Food",
      colour: "red"
    )

    second = Category.new(
      id: 5,
      title: "Completely Different",
      colour: "green"
    )

    assert_equal first, second
  end

  def test_categories_with_different_ids_are_not_equal
    first = Category.new(
      id: 1,
      title: "Food",
      colour: "red"
    )

    second = Category.new(
      id: 2,
      title: "Food",
      colour: "red"
    )

    refute_equal first, second
  end

  def test_hash_uses_id
    first = Category.new(id: 1, title: "Food", colour: "red")
    second = Category.new(id: 1, title: "Other", colour: "green")

    hash = {
      first => "hello"
    }

    assert_equal "hello", hash[second]
  end
end