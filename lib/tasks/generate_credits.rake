namespace :git do
  desc 'Generate credits file from the github contributors list'
  task :generate_credits do
    write_file(Rails.root.to_s + '/doc/credits', `git shortlog -sne | cut -f2 | sort -t\\< -k2b -u | sort`)
  end
end
def write_file(name, content)
  puts "Writing #{name}..."
  File.open(name, 'w') do |file|
    file.write content
  end
end
