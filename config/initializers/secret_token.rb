# Temporarily rescuing to Nil to avoid errors when generating assets
# TODO: Need to look at a better solution, rake secrets?

Rails.application.config.secret_token = Security::SessionSecret.secret_token rescue nil
Rails.application.config.secret_key_base = Security::SessionSecret.secret_token rescue nil
