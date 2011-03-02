class AdvancedSearch
  include Validatable
  
  attr_reader :search_field
  attr_reader :search_value
  
  validates_presence_of :search_field, :search_value
  validates_length_of :search_value, :maximum => 150
  
  def initialize(search_field, search_value)
    @search_field = search_field
    @search_value = search_value
  end
end

