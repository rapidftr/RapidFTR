class ChildSearch
  def results
    search.execute.results
  end

  def paginated(page, per_page)
    search.build do
      paginate page: page, per_page: per_page
    end
    self
  end

  def ordered(field, direction)
    search.build do
      order_by Child.sortable_field_name(field), direction if field
    end
    self
  end

  def created_by user
    search.build do
      fulltext user.user_name do
        fields(:created_by)
      end
    end
    self
  end

  def marked_as field_to_filter
    search.build do
      with(field_to_filter.to_sym, true) if field_to_filter and !field_to_filter.empty?
    end
   self
  end

  private

  def search
    @search ||= Sunspot.new_search(Child)
  end
end
