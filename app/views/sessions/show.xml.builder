xml.instruct!
xml.session {
  xml.link( :rel => 'session', :uri => session_path(@session) )
  xml.token(@session.token)
}
