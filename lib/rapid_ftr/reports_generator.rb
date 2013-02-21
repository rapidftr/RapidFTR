module ReportsGenerator

  def generate
    # file_name = "#{Date.today.year}-#{Date.today.month}-#{Date.today.day}.csv"
    file_name = "#{Time.now}.csv"
    FasterCSV.open(File.join(Rails.root, "reports/#{file_name}"), "w") do |csv|
      csv << ["protection status", "gender", "ftr status", "total"]
      ["Unaccompanied", "Separated"].each do |protection_status|
        ["Male", "Female"].each do |gender|
          ["Identified", "Verified", "Tracing On-Going", 
            "Family Located-Cross-Border FR Pending", 
            "Family Located- Inter-Camp FR Pending", 
            "Reunited", "Exported to CPIMS", "Record Invalid"
          ].each do |ftr_status|
            csv << [protection_status, gender, ftr_status,  Child.by_protection_status_and_gender_and_ftr_status(:key => [protection_status, gender, ftr_status]).size]
          end
        end
      end
    end
  end

end
