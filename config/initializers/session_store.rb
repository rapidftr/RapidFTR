Rails.application.config.session_store :encrypted_cookie_store, {
  # name of the encrypted cookie
  key: '_session',

  # cookie expiry *not* session expiry,
  expire_after: 1.week,

  # rapidftr options
  rapidftr: {
    web_expire_after: 20.minutes,
    mobile_expire_after: 20.minutes
  }
}
