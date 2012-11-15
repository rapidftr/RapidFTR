module AdvancedSearchHelper
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
    html = %Q{<p>}
    if criteria.index.to_i > 0
      html += %Q{<input id="criteria_join_and" type="radio" value="AND" #{(criteria.join == "AND") ? "checked=\"\"" : ""} name="criteria_list[1][join]">
<label for="criteria_join_and">And</label>
<input id="criteria_join_or" type="radio" value="OR"#{(criteria.join == "OR") ? "checked=\"\"" : ""} name="criteria_list[1][join]">
<label for="criteria_join_or">Or</label>}
    end
    html += %Q{<a class="select-criteria">#{criteria.field_display_name}</a>}
    html += %Q{<input class="criteria-field" type="hidden" value="#{criteria.field}" name="criteria_list[#{criteria.index}][field]">}
    html += %Q{<input class="criteria-index" type="hidden" value="#{criteria.index}" name="criteria_list[#{criteria.index}][index]">}
    if field.type == Field::SELECT_BOX
      html += %Q{<select class="criteria-value-select" value="" name="criteria_list[#{criteria.index}][value]" style="">}
      field.option_strings.each{|option| html += "<option #{criteria.value == option ? "selected=\"selected\"" : ""} value=\"#{option}\">#{option}</option>"}
      html += "</select>"
    else
      html += %Q{<input class="criteria-value-text" type="text" value="#{criteria.value}" name="criteria_list[#{criteria.index}][value]" style="">}
    end
    html += "<a class=\"remove-criteria\">remove</a>" if criteria.index.to_i > 0
    html += "</p>"
  end
end
