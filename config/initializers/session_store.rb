#Rails.application.config.session_store :encrypted_cookie_store, :expire_after => 20.minutes
Rails.application.config.session_store :cookie_store, :session_expires => 20.minutes
