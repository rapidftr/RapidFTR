class FormSectionRepository
  def self.all
     FormSectionDefinition.all().collect {|item| FormSection.new(item.name)}
  end
end