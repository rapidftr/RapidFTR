module CustomMatchers
  class AttachmentResponse
    def initialize(file, disposition = 'attachment', filename = nil)
      @data = file.data
      @content_type = file.content_type
      @disposition = disposition
      @failure_reasons = []
      @filename = filename
    end

    def matches?(response)
      verify { [response.content_type == @content_type, "content type is #{response.content_type} instead of #{@content_type}"] } &&
          verify { [response.body == @data, "data is different"] } &&
          verify do
            result = response_has_specified_disposition? response
            [result, "content disposition is #{response.headers['Content-Disposition']} instead of #{@disposition}"]
          end &&
          verify { @filename.nil? || has_filename?(@filename) }
    end

    def failure_message
      "does not match expected attachment\n" + @failure_reasons.join('\n')
    end

    private

    def verify
      result, failure = yield
      @failure_reasons << "#{failure}" if !result
      result
    end

    def response_has_specified_disposition?(response)
      response.headers.key?('Content-Disposition') && response.headers['Content-Disposition'].index(@disposition)
    end

    def has_filename?(filename)
      response.headers['Content-Disposition'].include? ";filename=#{filename}"
    end
  end

  def represent_attachment(file, filename = nil)
    AttachmentResponse.new file, filename
  end

  def represent_inline_attachment(file)
    AttachmentResponse.new file, 'inline'
  end
end
