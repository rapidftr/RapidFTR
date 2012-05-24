class ChildrenPresenter
  @@composers = {
    "reunited" => ReunitedChildrenComposer,
    "flagged" => FlaggedChildrenComposer,
    "active" => ActiveChildrenComposer,
    "all" => AllChildrenComposer
  }

  attr_reader :children, :filter

  def initialize(children, status, order)
    @filter = status || 'all'
    @composer = get_composer(order)
    @children = @composer.compose(children)
  end

  delegate :order, :to => :@composer

  def get_composer(order)
    @@composers[@filter].new(order)
  end

end
