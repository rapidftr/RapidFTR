class FakeRecordWithHistory
  attr_reader :id

  def initialize(user = "Bob", created = "2010/12/31 22:06:00 +0000")
    @id = "ChildId"
    @fields = {
      "histories" => [],
      "created_at" => created,
      "created_by" => user
    }
  end

  def add_history(history)
    @fields["histories"].unshift(history)
  end

  def ordered_histories
    @fields["histories"]
  end

  def add_photo_change(username, date, *new_photos)
    self.add_history({
                       "changes" => {
                         "photo_keys" => {
                           "added" => new_photos
                         }
                       },
                       "user_name" => username,
                       "datetime" => date
                     })
  end

  def add_single_change(username, date, field, from, to)
    self.add_history({
                       "changes" => {
                         field => {
                           "from" => from,
                           "to" => to
                         }
                       },
                       "user_name" => username,
                       "datetime" => date
                     })
  end

  def [](field)
    @fields[field]
  end

  def last_updated_at
    Date.today
  end
end
