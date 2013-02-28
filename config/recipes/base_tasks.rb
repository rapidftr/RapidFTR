def template(from, to)
  temp = "/tmp/#{File.basename to}"
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), temp
  run "mv #{temp} #{to}"
  #CI will propmt for password if ran with sudo. Need to give full access for the deploy user to copy from /tmp to the required folder.
end

def run_with_path_env(task, options={}, &block)
  command = "cd #{current_path} && RAILS_ENV=#{rails_env} /usr/bin/env #{task}"
  run(command, options, &block)
end
