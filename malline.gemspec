Gem::Specification.new do |s|
  s.name = %q{malline}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Riku Palom\303\244ki"]
  s.date = %q{2008-09-01}
  s.default_executable = %q{malline}
  s.email = ["riku@palomaki.fi"]
  s.executables = ["malline"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["COPYING", "COPYING.LESSER", "History.txt", "Manifest.txt", "README", "README.txt", "Rakefile", "bin/malline", "github.rb", "init.rb", "lib/malline.rb", "lib/malline/adapters/rails-2.0.rb", "lib/malline/adapters/rails-2.1.rb", "lib/malline/erb_out.rb", "lib/malline/form_builder.rb", "lib/malline/plugin.rb", "lib/malline/plugins/xhtml.rb", "lib/malline/rails.rb", "lib/malline/template.rb", "lib/malline/view_proxy.rb", "lib/malline/view_wrapper.rb", "malline.gemspec", "scripts/html2mn.rb", "test/examples/_action.mn", "test/examples/_action.target", "test/examples/_one.mn", "test/examples/_one.target", "test/examples/_partial.mn", "test/examples/_partial.target", "test/examples/_three.rhtml", "test/examples/_two.mn", "test/examples/_two.target", "test/examples/capture.mn", "test/examples/capture.target", "test/examples/class.mn", "test/examples/class.target", "test/examples/escape.mn", "test/examples/escape.target", "test/examples/frontpage.mn", "test/examples/frontpage.target", "test/examples/hello_world.mn", "test/examples/hello_world.target", "test/examples/helper.mn", "test/examples/helper.target", "test/examples/helper2.mn", "test/examples/helper2.target", "test/examples/helper_shortcut.mn", "test/examples/helper_shortcut.target", "test/examples/id.mn", "test/examples/id.target", "test/examples/layout.mn", "test/examples/layout.target", "test/examples/lists.mn", "test/examples/lists.target", "test/examples/nested.mn", "test/examples/nested.target", "test/examples/options.mn", "test/examples/options.target", "test/examples/partials.mn", "test/examples/partials.target", "test/examples/self.mn", "test/examples/self.target", "test/examples/text.mn", "test/examples/text.target", "test/examples/whitespace.mn", "test/examples/whitespace.target", "test/examples/xhtml.mn", "test/examples/xhtml.target", "test/kernel.org.html", "test/kernel.org.mn", "test/malline_test.rb", "test/malline_test_helpers.rb"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{malline}
  s.rubygems_version = %q{1.2.0}
  s.summary = "Malline is a full-featured pure Ruby template system designed to be a replacement for ERB views in Rails or any other framework"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<hoe>, [">= 1.5.3"])
    else
      s.add_dependency(%q<hoe>, [">= 1.5.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.5.3"])
  end
end
