module ReportsGenerator

  def generate
    file_name = "#{Date.today.year}-#{Date.today.month}-#{Date.today.day}.csv"
    fields = FormSection.by_unique_id(:key => "basic_identity").first.fields
    protection_statuses = fields.find{|field| field[:name] == "protection_status"}.option_strings
    genders = fields.find{|field| field[:name] == "gender"}.option_strings
    ftr_statuses = fields.find{|field| field[:name] == "ftr_status"}.option_strings

      FasterCSV.open(File.join(Rails.root, "reports/#{file_name}"), "w") do |csv|
      csv << ["protection status", "gender", "ftr status", "total"]
      protection_statuses.each do |protection_status|
        genders.each do |gender|
          ftr_statuses.each do |ftr_status|
            csv << [protection_status, gender, ftr_status, Child.by_protection_status_and_gender_and_ftr_status(:key => [protection_status, gender, ftr_status]).size]
          end
        end
      end
    end
  end

end
