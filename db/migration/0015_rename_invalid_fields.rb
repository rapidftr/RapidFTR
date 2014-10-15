sections = FormSection.all.all
sections.each do |fs|
  next unless fs.form.nil?
  fs.form = Form.find_by_name(Child::FORM_NAME)
  next if fs.save
  invalid_fields = fs.fields.select { |f| !f.valid? }
  invalid_fields.each { |f| f.name = f.name + SecureRandom.hex[0..5] }
  fs.fields = invalid_fields.select { |f| f.valid? }
  fs.save
end
