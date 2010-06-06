class Summary < CouchRestRails::Document
  END_CHAR_AVOIDER = "aa"
  use_database :child

  view_by :name,
          :map => "function(doc) {
              if ((doc['couchrest-type'] == 'Child') && doc['name'])
             {
                emit(doc['name'],doc);
             }
          }"

  view_by :unique_identifier,
          :map => "function(doc) {
              if ((doc['couchrest-type'] == 'Child') && doc['unique_identifier'])
             {
                emit(doc['unique_identifier'],doc);
             }
          }"
  
  def self.basic_search(child_name, unique_id)
    results = search_by_unique_identifier(unique_id)
    results = search_by_name(child_name) if results.nil?

    return [] unless results

    results.sort { |lhs,rhs| lhs["name"] <=> rhs["name"]} 
  end

  def self.advanced_search(field, value)
   Child.class_eval do
     view_by field.to_sym
   end
   
    Child.send("by_#{field}".to_sym, create_key_range(value))
  end

  def self.and_arrays(*arrays)
    non_empty_arrays = arrays.reject{ |x| x.nil? || x.empty? }
    return [] if non_empty_arrays.empty?

    non_empty_arrays.inject do |anded_array,array|
      anded_array &= array
    end
  end

  private
  def self.search_by_name(search_value)
    if (search_value && !search_value.empty?)
      args = create_key_range(search_value)
      Summary.view("by_name", args)
    end
  end

  def self.search_by_unique_identifier(search_value)
    if (search_value && !search_value.empty?)
      args = {:startkey => search_value, :endkey => search_value}
      Summary.view("by_unique_identifier", args)
    end
  end

  def self.create_key_range(from_value)
    endkey = from_value[0].chr.next

    args = {:startkey => from_value}
    args.store(:endkey, endkey) unless endkey == END_CHAR_AVOIDER

    args
  end
end
