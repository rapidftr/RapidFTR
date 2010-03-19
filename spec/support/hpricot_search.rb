module HpricotSearch
  def checkboxes
    search("p[@class=checkbox] input[@type='checkbox']")
  end

  def photos
    search("p[@class=photo]")
  end

  def definition_lists
    search("dl")
  end

  def profiles_list_items
    search("div[@class=profiles-list-item]")
  end

  def child_name
    search("h3")
  end
end