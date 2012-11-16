module AdvancedSearchHelper

  AND_OR = %Q{<input id="criteria_join_and" type="radio" value="AND" #AND_CHECKED name="criteria_list[#INDEX][join]">
<label for="criteria_join_and">And</label>
<input id="criteria_join_or" type="radio" value="OR" #OR_CHECKED name="criteria_list[#INDEX][join]">
<label for="criteria_join_or">Or</label>}
  DISPLAY_LABEL = %Q{<a class="select-criteria">#DISPLAY_NAME</a>}
  FIELD_INDEX = %Q{<input class="criteria-field" type="hidden" value="#FIELD" name="criteria_list[#INDEX][field]">
<input class="criteria-index" type="hidden" value="#INDEX" name="criteria_list[#INDEX][index]">}
  REMOVE_LINK = "<a class=\"remove-criteria\">remove</a>"

  def empty_lines(fields)
    if (@forms.size > fields.size )
      @forms.size - fields.size
    else
      0
    end
  end

  def generate_html(criteria, all_fields)
    return "" if criteria.field.blank?
    field = all_fields.find{|field| field.name == criteria.field}
    html = criteria.index.to_i > 0 ? AND_OR.gsub("#AND_CHECKED", criteria.join == "AND" ?  "checked=''" : "").gsub("#OR_CHECKED", criteria.join == "OR" ?  "checked=''" : "") : ""
    html += DISPLAY_LABEL.gsub("#DISPLAY_NAME", criteria.field_display_name)
    html += FIELD_INDEX.gsub("#FIELD", criteria.field)
    html += send(field.type, criteria, field)
    html += REMOVE_LINK if criteria.index.to_i > 0
    "<p>#{html.gsub("#INDEX", criteria.index)}</p>"
  end

  private
  def select_box(criteria, field)
    html = %Q{<select class="criteria-value-select" value="" name="criteria_list[#INDEX][value]" style="">}
    field.option_strings.each{|option| html += "<option #{criteria.value == option ? "selected=\"selected\"" : ""} value=\"#{option}\">#{option}</option>"}
    html += "</select>"
  end

  def text_field(criteria, field)
    %Q{<input class="criteria-value-text" type="text" value="#{criteria.value}" name="criteria_list[#INDEX][value]" style="">}
  end

  def textarea(criteria, field)
    text_field(criteria, field)
  end
end
