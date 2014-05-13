class ChildRecordToolbarWidget

  def initialize(session)
    @session = session
  end

  def view_user_action_history
    @session.find(:xpath, "//a[@class='btn']").click
  end

  def mark_as_investigated(details)
    @session.click_link('Mark as Investigated')
    @session.fill_in('Investigation Details', :with => details)
    @session.click_button('Mark as Investigated')
  end

  def mark_as_not_investigated(details)
    @session.click_link('Mark as Not Investigated')
    @session.fill_in('Undo Investigation Details', :with => details)
    @session.click_button('Undo Investigated')
  end

end