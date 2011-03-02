module AdvancedSearchHelper
  def empty_lines(fields)
    if (@forms.size > fields.size )
      @forms.size - fields.size 
    else
      0
    end
  end
end