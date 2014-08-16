module AdvancedSearchHelper

  AND_OR = %{<input id="criteria_join_and" type="radio" value="AND" #AND_CHECKED name="criteria_list[#INDEX][join]">
<label for="criteria_join_and">And</label>
<input id="criteria_join_or" type="radio" value="OR" #OR_CHECKED name="criteria_list[#INDEX][join]">
<label for="criteria_join_or">Or</label>}
  DISPLAY_LABEL = %{<a class="select-criteria">#DISPLAY_NAME</a>}
  FIELD_INDEX = %{<input class="criteria-field" type="hidden" value="#FIELD" name="criteria_list[#INDEX][field]">
<input class="criteria-index" type="hidden" value="#INDEX" name="criteria_list[#INDEX][index]">}
  REMOVE_LINK = "<a class=\"remove-criteria\">remove</a>"

  def empty_lines(fields)
    if (@form_sections.size > fields.size )
      @form_sections.size - fields.size
    else
      0
    end
  end

  def generate_html(criteria, all_fields)
    field = all_fields.find{ |field| field.name == criteria[:field] }
    return "" unless field.present?

    html = criteria[:index].to_i > 0 ? AND_OR.gsub("#AND_CHECKED", criteria[:join] == "AND" ?  "checked=''" : "").gsub("#OR_CHECKED", criteria[:join] == "OR" ?  "checked=''" : "") : ""
    html += DISPLAY_LABEL.gsub("#DISPLAY_NAME", field.display_name)
    html += FIELD_INDEX.gsub("#FIELD", field.name)
    html += send("#{field.type}_criteria", criteria, field)
    html += REMOVE_LINK
    "<p class='criterion-selected'>#{html.gsub("#INDEX", criteria[:index])}</p>"
  end

  private

  def select_box_criteria(criteria, field)
    html = %{<span class="criteria-values"/><select class="criteria-value-select" value="" name="criteria_list[#INDEX][value]" style="">}
    field.option_strings.each{|option| html += "<option #{criteria[:value] == option ? "selected=\"selected\"" : ""} value=\"#{option}\">#{option}</option>"}
    html += "</select>"
  end

  def text_field_criteria(criteria, field)
    %{<span class="criteria-values"/><input class="criteria-value-text" type="text" value="#{criteria[:value]}" name="criteria_list[#INDEX][value]" style="">}
  end

  def textarea_criteria(criteria, field)
    text_field_criteria(criteria, field)
  end
end
