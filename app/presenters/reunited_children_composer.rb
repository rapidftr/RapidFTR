class ReunitedChildrenComposer

  attr_reader :order

  def initialize(order)
    @order = order
    @order ||= 'name'
  end

  def compose(children)
    reunited_children = select(children)
    apply_reunited_at(reunited_children)
    sort(reunited_children)
  end

  def select(children)
    children.select { |c| c.reunited? }
  end

  def sort(children)
    if order == 'most recently reunited'
      children.sort!{ |x,y| y['reunited_at'] <=> x['reunited_at'] }
    else
      children.sort!{ |x,y| x['name'] <=> y['name'] }
    end
  end

  def apply_reunited_at(children)
    children.each { |child|
      child['reunited_at'] = child['histories'].select{ |h| h['changes'].keys.include?('reunited') }.map{ |h| h['datetime'] }.max
    }
  end
end
