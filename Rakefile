# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "oscope"
  gem.homepage = "http://github.com/tduehr/oscope"
  gem.license = "MIT"
  gem.summary = %Q{SCPI command interface}
  gem.description = %Q{SCPI (IEEE 488.2) interface. Only the Rigol DS1102D oscilloscope is implemented currently. All SCPI interfaces *should* be supported.}
  gem.email = "tduehr@gmail.com"
  gem.authors = ["tduehr"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
