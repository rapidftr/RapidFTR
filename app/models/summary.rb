class Summary < CouchRestRails::Document
  use_database :child

  view_by :user_name,
          :map => "function(doc) {
              if ((doc['couchrest-type'] == 'Child') && doc['user_name'])
             {
                emit(doc['user_name'],doc);
             }
          }"
  view_by :name,
          :map => "function(doc) {
              if ((doc['couchrest-type'] == 'Child') && doc['name'])
             {
                emit(doc['name'],doc);
             }
          }"


  def self.basic_search(user_name, childs_name)
    x = get_keys_for_search(childs_name, "by_name")
    y = get_keys_for_search(user_name, "by_user_name")
    return x if y == nil
    return y if x == nil
    return x.select { |doc| y.include?(doc)}
  end

  private
  def self.get_keys_for_search(childs_name, view_to_search)
    if (childs_name && !childs_name.empty?)
      args = create_start_key_end_key(childs_name)
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