class Search
  include Validatable

  attr_accessor :query
  attr_accessor :limitation

  validates_presence_of :query
  validates_length_of :query, :maximum => 150
  validates_format_of :query, :if => Proc.new{|search| !search.query.empty?}, :with => /^([\w ]+)$/, :message => "must only be letters (a to z) or numbers (0-9). Please try again with a different key word."

  def initialize(query, limitation = {})
    @query = query.strip
    @limitation = limitation
  end

end
