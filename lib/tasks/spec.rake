require "rspec/core/rake_task"

use_spec_opts = ['--options', Rails.root.join('spec', 'spec.opts')]

RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = use_spec_opts
end

namespace :spec do
  sub_spec_dirs = Dir[Rails.root.join("spec", "*")].
    select {|p| File.directory? p }.
    map {|p| File.basename p } -
    %w( fixtures javascripts resources support )

  sub_spec_dirs.each do |sub_spec_dir|
    desc "Run the code examples in spec/#{sub_spec_dir}"
    RSpec::Core::RakeTask.new sub_spec_dir do |t|
      t.spec_opts = use_spec_opts
      t.pattern = Rails.root.join('spec', sub_spec_dir, '**', '*_spec.rb')
    end
  end
end
