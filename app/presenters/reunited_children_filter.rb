class ReunitedChildrenFilter

  attr_reader :children, :order

  def initialize(children, order)
    @children = children
    @order = order
    @order ||= 'name'
  end

  def compose
    sort(select(children), order)
  end

  def select(children)
    children.select { |c| c.reunited? }
  end

  def sort(children, order)
    if order == 'most recently reunited'
      children.each { |child|
        child['reunited_at'] = child['histories'].select{ |h| h['changes'].keys.include?('reunited') }.map{ |h| h['datetime'] }.max
      }
      children.sort!{ |x,y| y['reunited_at'] <=> x['reunited_at'] }
    else
      children.sort!{ |x,y| x['name'] <=> y['name'] }
    end
  end
end
