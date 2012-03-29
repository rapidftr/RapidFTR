class FlaggedChildrenFilter

  attr_reader :children, :order

  def initialize(children, order)
    @children = children
    @order = order
    @order ||= 'most recently flagged'
  end

  def compose
    sort(select(children), order)
  end

  def select(children)
    children.select { |c| c.flag? }
  end

  def sort(children, order)
    children.each { |child|
      child['flagged_at'] = child['histories'].select{ |h| h['changes'].keys.include?('flag') }.map{ |h| h['datetime'] }.max
    }
    if order == 'most recently flagged'
      children.sort!{ |x,y| y['flagged_at'] <=> x['flagged_at'] }
    else
      children.sort!{ |x,y| x['name'] <=> y['name'] }
    end
  end
end
