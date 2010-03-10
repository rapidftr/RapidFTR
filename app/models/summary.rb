class Summary < CouchRestRails::Document
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


  def self.basic_search(childs_name, unique_id)
    x = get_keys_for_search(childs_name, "by_name")
    y = get_keys_for_search(unique_id, "by_unique_identifier")

    return [] if x == y && x == nil
    results = and_arrays(x, y)
    results.sort { |lhs,rhs| lhs["name"] <=> rhs["name"]}
  end

  def self.and_arrays(*arrays)
    non_empty_arrays = arrays.reject{ |x| x.nil? || x.empty? }
    return [] if non_empty_arrays.empty?

    non_empty_arrays.inject do |anded_array,array|
      anded_array &= array
    end
  end

  private
  def self.get_keys_for_search(search_value, view_to_search)
    if (search_value && !search_value.empty?)
      args = create_start_key_end_key(search_value)
      Summary.view(view_to_search, args)
    end
  end

  def self.create_start_key_end_key(from_value)
    endkey = from_value[0].chr.next
    args = {:startkey => from_value}

    args.store(:endkey, endkey) unless endkey == "aa"
    args
  end
end
