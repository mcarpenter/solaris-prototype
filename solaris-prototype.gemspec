Gem::Specification.new do |s|
  s.authors = [ 'Martin Carpenter' ]
  s.date = Time.now.strftime('%Y-%m-%d')
  s.description = 'Parse and write Solaris package prototype records'
  s.email = 'mcarpenter@free.fr'
  s.extra_rdoc_files = %w{ LICENSE Rakefile README.rdoc }
  s.files = FileList[ 'lib/**/*', 'test/**/*' ].to_a
  s.has_rdoc = true
  s.homepage = 'http://mcarpenter.org/projects/solaris-prototype'
  s.licenses = [ 'BSD' ]
  s.name = 'solaris-prototype'
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = nil
  s.summary = 'Parse and write Solaris package prototype records'
  s.test_files = FileList[ "{test}/**/test_*.rb" ].to_a
  s.version = '1.0.0'
end

