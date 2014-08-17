Rails.application.config.session_store :cookie_store, {
  # name of the encrypted cookie
  :key => '_rftr_session',

  # cookie expiry *not* session expiry,
  :expire_after => 1.week,

  # rapidftr options
  :rapidftr => {
    :web_expire_after => 20.minutes,
    :mobile_expire_after => 20.minutes
  }
}
