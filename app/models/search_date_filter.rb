class SearchDateFilter < SearchCriteria

  attr_accessor :from_value, :to_value
  OFFSET_INDEX = 200

  def initialize(params = {})
      super params
      @from_value = params[:from_value] || ""
      @to_value = params[:to_value] || ""
      @index = (@index.to_i + OFFSET_INDEX).to_s
  end

  def to_lucene_query
    "(#{field}_d:[#{from_value} #{to_value}])"
  end

end