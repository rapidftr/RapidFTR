module ChildFinder
  def find_child_by_name child_name
    child = Child.by_name(:key => child_name)
    raise "no child named '#{child_name}'" if child.nil?
    child.first
  end
end
