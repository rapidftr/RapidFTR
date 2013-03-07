 RapidFTR::Application.configure do
 config.middleware.use "Rack::Bug",
  :ip_masks   => nil,
  :secret_key => "someverylongsecretivesecretkey",
  :password   => "welcometothejungle" 
end