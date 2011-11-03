module AdvancedSearchHelper
  def empty_lines(fields)
    if (@forms.size > fields.size )
      @forms.size - fields.size 
    else
      0
    end
  end

  def date_filter_note
  	"Enter a date in the first box to search records created or updated after that date. " +
  	"Enter a date in the second box to see records created or updated before that date. " + 
  	"Enter dates in both boxes to see records created between the dates."
  end
end