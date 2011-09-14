require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems/package_task'

desc 'Default task (package)'
task :default => [:package]

Rake::TestTask.new( 'test' )

SPECFILE = 'solaris-prototype.gemspec'
if File.exist?( SPECFILE )
  spec = eval( File.read( SPECFILE ) )
  #Rake::GemPackageTask.new( spec ).define
  Gem::PackageTask.new( spec ).define
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'solaris-prototype'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.options << '--all'
  rdoc.rdoc_files.include( 'README.rdoc' )
  rdoc.rdoc_files.include( FileList[ 'lib/**/*' ] )
  rdoc.rdoc_files.include( FileList[ 'test/**/*' ] )
end

