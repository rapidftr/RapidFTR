class Search
  include Validatable

  attr_accessor :query

  validates_presence_of :query
  validates_length_of :query, :maximum => 150
  validates_format_of :query, :with => /^([\w ]+)$/, :message => "must only be letters (a to z) or numbers (0-9). Please try again with a different key word."

  def initialize(query)
    @query = query.strip
  end

end