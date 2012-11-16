def template(from, to)
  temp = "/tmp/#{File.basename to}"
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), temp
  run "mv #{temp} #{to}"
end

def run_rake(task, options={}, &block)
  command = "cd #{fetch :current_path} && RAILS_ENV=#{fetch :deploy_env} /usr/bin/env bundle exec rake #{task}"
  run(command, options, &block)
end
