require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run unit tests.'
task :default => :spec

desc "Run all has_ancestor plugin specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['test/rails_root/spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'test/rails_root/spec/spec.opts']
end

desc "Run specified has_ancestor plugin spec"
Spec::Rake::SpecTask.new(:spec_file) do |t|
  file = ENV["FILE"] || ''
  t.spec_files = ["test/rails_root/spec/**/#{file}.rb"]
  t.spec_opts = ['--options', 'test/rails_root/spec/spec.opts']
end

desc "Generate HTML report for all has_ancestor specs"
Spec::Rake::SpecTask.new(:spec_report) do |t|
  t.spec_files = FileList['test/rails_root/spec/**/*_spec.rb']
  t.spec_opts = ['--format', 'html:adlib_spec_report.html', '--diff']
  t.fail_on_error = false
end

desc "Generate HTML report for specified spec"
Spec::Rake::SpecTask.new(:spec_report_file) do |t|
  file = ENV["FILE"] || ''
  t.spec_files = ["test/rails_root/spec/**/#{file}.rb"]
  t.spec_opts = ['--format', "html:#{file}.html", '--diff']
  t.fail_on_error = false
end

desc 'Generate documentation for the has_ancestor plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'adlib'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
