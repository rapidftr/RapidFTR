class ActiveChildrenComposer

  attr_reader :order

  def initialize(order)
    @order = order
    @order ||= 'name'
  end

  def compose(children)
    non_reunited_children = select(children)
    sort(non_reunited_children)
  end

  def select(children)
    children.select { |c| !c.reunited? }
  end

  def sort(children)
    if order == 'most recently created'
      children.sort!{ |x,y| y['created_at'] <=> x['created_at'] }
    else
      children.sort!{ |x,y| (x['name'] || '') <=> (y['name'] || '') }
    end
  end
end
