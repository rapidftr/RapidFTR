FormSection.all.all.each do |fs|
  if fs.form.nil?
    fs.form = Form.find_by_name(Child::FORM_NAME)
    fs.save
  end
end
