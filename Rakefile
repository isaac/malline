require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the malline plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the malline plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Malline'
  rdoc.options += %w[ --line-numbers --inline-source --all
		--charset=UTF-8 --tab-width=2
		--webcvs=http://dev.malline.org/browser/trunk/malline/%s#L1 ]
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

summary = <<-EOF
	Malline is a full-featured pure Ruby template system designed to be
	a replacement for ERB views in Rails or any other framework. See
	http://www.malline.org/ for more info.
EOF

desc = <<-EOF
	Malline is a full-featured template system designed to be
	a replacement for ERB views in Rails or any other framework.
	It also includes standalone bin/malline to compile Malline
	templates to XML in commandline. All Malline templates are
	pure Ruby, see http://www.malline.org/ for more info.
EOF

begin
	require 'rubygems'
	require 'rake/gempackagetask'
	PKG_FILES = FileList['lib/**/*.rb', 'bin/*', 'COPYING*', 'README', 'scripts/*rb', 'test/*', 'test/examples/*']
	PKG_VERSION = File.read('README').scan(/^Malline (\d+\.\d+\.\d+)/).first.first
	spec = Gem::Specification.new do |s|
		s.author = 'Riku Palomäki'
		s.email = 'riku@palomaki.fi'
		s.executables = ['malline']
		s.extra_rdoc_files = ['README']
		s.files = PKG_FILES.to_a
		s.homepage = 'http://www.malline.org/'
		s.name = 'malline'
		s.rubyforge_project = 'malline'
		s.summary = summary
		s.test_file = 'test/malline_test.rb'
		s.version = PKG_VERSION
		s.description = desc
		s.has_rdoc = true
	end

	Rake::GemPackageTask.new(spec) do |pkg|
		pkg.need_zip = true
		pkg.need_tar = true
	end
rescue LoadError => e
	warn e.message
	warn 'Warning: Package building is disabled because of missing libs'
end

require 'hoe'

Hoe.new('malline', '1.1.0') do |p|
  p.developer 'Riku Palomäki', 'riku@palomaki.fi'
end
