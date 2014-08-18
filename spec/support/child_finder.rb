Child.class_eval do
  design do
    view :by_name,
         :map => "function(doc) {
             if (doc['couchrest-type'] == 'Child')
            {
               if (!doc.hasOwnProperty('duplicate') || !doc['duplicate']) {
                 emit(doc['name'], doc);
               }
            }
         }"
  end
end

module ChildFinder
  def find_child_by_name(child_name)
    child = Child.by_name(:key => child_name)
    fail "no child named '#{child_name}'" if child.nil?
    child.first
  end
end
