module CleanupEncryptedFiles

  CLEANUP_TIME = 10.minutes

  def self.dir_name
    File.join Rails.root, 'tmp', 'encrypted_data'
  end

  def self.schedule(scheduler)
    scheduler.every("30m") do
      begin
        Rails.logger.info "Cleaning up temporary encrypted files..."
        cleanup!
      rescue => e
        Rails.logger.error "Error cleaning up temporary encrypted files"
        e.backtrace.each { |line| Rails.logger.error line }
      end
    end
  end

  def self.cleanup!
    Dir.glob(File.join(self.dir_name, "*.zip")) do |zip_file|
      if File.mtime(zip_file) < CLEANUP_TIME.ago
        File.delete zip_file
      end
    end
  end

end
