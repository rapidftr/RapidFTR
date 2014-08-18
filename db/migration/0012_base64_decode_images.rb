require 'progress_bar'
require 'base64'

rows = Child.database.all_docs['rows']
progressbar = ProgressBar.new rows.count if rows.count > 0
errors = []

rows.each do |row|
  begin
    doc = Child.database.get row['id']
    attachments = doc['_attachments']
    attachments.each do |attachment_id, attachment_meta|
      next unless attachment_meta['content_type'].start_with? 'image/'
      data = Child.database.fetch_attachment doc, attachment_id
      begin
        MiniMagick::Image.read data
      rescue MiniMagick::Invalid
        data64 = Base64.decode64 data
        MiniMagick::Image.read data64
        Child.database.put_attachment doc, attachment_id, data64
        doc = Child.database.get row['id']
      end
    end if doc['_attachments']
  rescue => e
    if errors.count == 0
      logger.error('Logging the first error, further errors will be suppressed')
      logger.error(e.message)
      logger.error(e.backtrace)
    end

    errors << row['id']
  end

  progressbar.increment!
end

if errors.count > 0
  logger.error('Failed to migrate images for following records:')
  logger.error(errors)
  fail 'Migration failed' unless ENV['IGNORE_0012'] == 'true'
end
