module ReportsGenerator

  def self.generate
    reports_dir = File.join(Rails.root, "reports")
    FileUtils.mkdir_p reports_dir

    file_name = "#{Date.today.year}-#{Date.today.month}-#{Date.today.day}.csv"
    fields = FormSection.by_unique_id(:key => "basic_identity").first.fields
    protection_statuses = fields.find{|field| field[:name] == "protection_status"}.option_strings
    genders = fields.find{|field| field[:name] == "gender"}.option_strings
    ftr_statuses = fields.find{|field| field[:name] == "ftr_status"}.option_strings
      FasterCSV.open(File.join(reports_dir, file_name), "w") do |csv|
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

  def self.schedule(scheduler)
    scheduler.cron '0 1 0 ? * MON' do # every monday at 00:01
      begin
        Rails.logger.info "Generating report..."
        ReportsGenerator.generate
      rescue => e
        Rails.logger.error "Error generating report"
        e.backtrace.each { |line| Rails.logger.error line }
      end
    end
  end

end
