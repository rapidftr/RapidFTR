Delayed::Worker.delay_jobs = !(Rails.env.test? || Rails.env.cucumber?)
