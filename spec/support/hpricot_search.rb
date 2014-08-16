module HpricotSearch
  def checkboxes
    search("p[@class=checkbox] input[@type='checkbox']")
  end

  def photos
    search("div[@class=photo_panel]")
  end

  def definition_lists
    search("dl")
  end

  def profiles_list_items
    search("div[@class=child_summary_panel]")
  end

  def child_name
    search("h3")
  end

  def child_tab
    search(".tab-handles a")
  end

  def child_tab_name
    search(".edit-profile h3")
  end

  def form_section_names
    search("#form_sections tr td a.formSectionLink")
  end

  def form_section_enabled_icons
    search(".formSectionEnabledIcon")
  end

  def form_section_rows
    search("#form_sections tr")
  end

  def form_section_row_for(form_section_id)
    at("##{form_section_id}_row")
  end

  def enabled_icon
    at(".field_hide_show")
  end

  def form_section_order
    at(".formSectionOrder")
  end

  def manage_fields_link
    at(".manageFieldsLink")
  end

  def add_custom_field_link
    at('a[text()="Add Custom Field"]')
  end

  def form_fields_list
    at("#formFields")
  end

  def form_field_for(field_id)
    at("##{field_id}Row")
  end

  def link_for(link_title)
    search("a[text()=\"#{link_title}\"]")
  end

  def submit_for(submit_text)
    search("input[@value='#{submit_text}']")
  end
end

class String
  def has_tag?(tag)
    !Nokogiri::HTML.parse(self).css(tag).empty?
  end
end
