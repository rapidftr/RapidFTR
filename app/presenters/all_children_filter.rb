class AllChildrenFilter

  attr_reader :children, :order

  def initialize(children, order)
    @children = children
    @order = order
    @order ||= 'name'
  end

  def compose
    sort(children)
  end

  def sort(children)
    if order == 'most recently created'
      children.sort!{ |x,y| y['created_at'] <=> x['created_at'] }
    else
      children.sort!{ |x,y| x['name'] <=> y['name'] }
    end
  end
end
