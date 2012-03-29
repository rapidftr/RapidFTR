class ChildrenPresenter
  @@composers = {
    "reunited" => ReunitedChildrenFilter,
    "flagged" => FlaggedChildrenFilter,
    "active" => ActiveChildrenFilter,
    "all" => AllChildrenFilter
  }

  attr_reader :children, :filter

  def initialize(children, status, order)
    @filter = status || 'all'
    @composer = composer(children, order)
    @children = @composer.compose
  end

  delegate :order, :to => :@composer

  def composer(children, order)
    @@composers[@filter].new(children, order)
  end

end
