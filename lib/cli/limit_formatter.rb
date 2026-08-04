class LimitFormatter
  # @param rows [Hash] => { id: Integer, category_id: Integer, merchant: String, amount: Float, period_type: String }
  def format(rows)
    rows.each do |r|
      puts r
    end
  end
end