module CustomMatchers
  class AttachmentResponse
    def initialize(file, disposition = 'attachment', filename = nil )
      @data = file.read
      @content_type = file.content_type
      @disposition = disposition
      @failure_reasons = []
      @filename = filename
    end

    def matches?(response)
      verify { [response.content_type == @content_type, "content type is #{response.content_type} instead of #{@content_type}"] } &&
          verify { [response.body == @data, "data is different"] } &&
          verify do
            result = does_response_have_specified_disposition(response)
            [ result, "content disposition is #{response.headers['Content-Disposition']} instead of #{@disposition}"]
          end &&
          verify { @filename.nil? || does_have_filename(@filename) }
          
    end

    def failure_message_for_should
      "does not match expected attachment\n" + @failure_reasons.join('\n')
    end

    private

    def verify
      result, failure = yield
      @failure_reasons << "#{failure}" if !result
      result
    end

    def does_response_have_specified_disposition(response)
      response.headers.has_key?('Content-Disposition') && response.headers['Content-Disposition'].index(@disposition)
    end
    
    def does_have_filename filename
      response.headers['Content-Disposition'].index( ";filename=#{filename}" )
    end
  end

  def represent_attachment(file, filename = nil)
    AttachmentResponse.new file, filename
  end

  def represent_inline_attachment(file)
    AttachmentResponse.new file, 'inline'
  end
end

