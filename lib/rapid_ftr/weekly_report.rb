module WeeklyReport
  REPORT_TYPE = 'weekly_report'

  def self.data
    fields = FormSection.by_unique_id(:key => "basic_identity").first.fields
    protection_statuses = fields.find { |field| field[:name] == "protection_status" }.option_strings
    genders = fields.find { |field| field[:name] == "gender" }.option_strings
    ftr_statuses = fields.find { |field| field[:name] == "ftr_status" }.option_strings

    csv_str = CSV.generate do |csv|
      csv << ["protection status", "gender", "ftr status", "total"]
      protection_statuses.each do |protection_status|
        genders.each do |gender|
          ftr_statuses.each do |ftr_status|
            csv << [protection_status, gender, ftr_status, Child.by_protection_status_and_gender_and_ftr_status(:key => [protection_status, gender, ftr_status]).all.size]
          end
        end
      end
    end

    StringIO.new csv_str
  end

  def self.generate!
    w = Report.new :as_of_date => Date.today, :report_type => REPORT_TYPE
    w.create_attachment :name => Date.today.strftime("weekly-report-%Y-%m-%d.csv"), :file => self.data, :content_type => 'text/csv'
    w.save!
    w
  end

  def self.schedule(scheduler)
    scheduler.cron '1 0 * * MON' do # every monday at 00:01
      begin
        Rails.logger.info "Generating report..."
        generate!
      rescue => e
        Rails.logger.error "Error generating report"
        e.backtrace.each { |line| Rails.logger.error line }
      end
    end
  end
end
