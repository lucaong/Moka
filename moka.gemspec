# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{moka}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luca Ongaro"]
  s.date = %q{2010-11-16}
  s.default_executable = %q{moka}
  s.description = %q{Moka is a damn simple framework designed to build static websites like portfolios, showcases, minisites, HTML mockups, etc. Moka setup takes a single command, and it provides a hierarchical template system and some hyper-convenient helper functions so you never have to write more code than necessary. The result of your work is compiled to plain HTML, CSS and Javascript, so you just have to upload it to your server. Plus, don't forget the Lipsum helper functions to generate dummy text with a single line of code during development or in HTML mockups.}
  s.email = %q{mail@lucaongaro.eu}
  s.executables = ["moka"]
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc", "bin/moka", "lib/commands.rb", "lib/commands/compile.rb", "lib/commands/delete.rb", "lib/commands/group/delete.rb", "lib/commands/group/group_generator.rb", "lib/commands/group/inspect.rb", "lib/commands/group/new.rb", "lib/commands/group/template/groupdir/variables.yml", "lib/commands/inspect.rb", "lib/commands/lib/compiler.rb", "lib/commands/lib/helpers.rb", "lib/commands/lib/lipsum_constants.rb", "lib/commands/lib/lipsum_helpers.rb", "lib/commands/lib/page_scope.rb", "lib/commands/lib/partials_inclusion.rb", "lib/commands/lib/site_tree.rb", "lib/commands/lib/string_inflectors.rb", "lib/commands/lib/utilities.rb", "lib/commands/new.rb", "lib/commands/order_groups.rb", "lib/commands/order_pages.rb", "lib/commands/page/delete.rb", "lib/commands/page/inspect.rb", "lib/commands/page/new.rb", "lib/commands/page/page_generator.rb", "lib/commands/page/template/pagedir/variables.yml", "lib/commands/server.rb", "lib/commands/site/inspect.rb", "lib/commands/site/new.rb", "lib/commands/site/site_generator.rb", "lib/commands/site/template/manifest.yml", "lib/commands/site/template/project/lib/helpers.rb", "lib/commands/site/template/project/site/content.erb", "lib/commands/site/template/project/site/header.erb", "lib/commands/site/template/project/site/layout.erb", "lib/commands/site/template/project/site/navigation.erb", "lib/commands/site/template/project/site/variables.yml", "lib/commands/site/template/project/styles/style.sass", "lib/commands/site/template/script/config/boot.rb", "lib/commands/site/template/script/moka", "lib/script_moka_loader.rb", "lib/version.rb"]
  s.files = ["LICENSE.txt", "Manifest", "README.rdoc", "Rakefile", "bin/moka", "lib/commands.rb", "lib/commands/compile.rb", "lib/commands/delete.rb", "lib/commands/group/delete.rb", "lib/commands/group/group_generator.rb", "lib/commands/group/inspect.rb", "lib/commands/group/new.rb", "lib/commands/group/template/groupdir/variables.yml", "lib/commands/inspect.rb", "lib/commands/lib/compiler.rb", "lib/commands/lib/helpers.rb", "lib/commands/lib/lipsum_constants.rb", "lib/commands/lib/lipsum_helpers.rb", "lib/commands/lib/page_scope.rb", "lib/commands/lib/partials_inclusion.rb", "lib/commands/lib/site_tree.rb", "lib/commands/lib/string_inflectors.rb", "lib/commands/lib/utilities.rb", "lib/commands/new.rb", "lib/commands/order_groups.rb", "lib/commands/order_pages.rb", "lib/commands/page/delete.rb", "lib/commands/page/inspect.rb", "lib/commands/page/new.rb", "lib/commands/page/page_generator.rb", "lib/commands/page/template/pagedir/variables.yml", "lib/commands/server.rb", "lib/commands/site/inspect.rb", "lib/commands/site/new.rb", "lib/commands/site/site_generator.rb", "lib/commands/site/template/manifest.yml", "lib/commands/site/template/project/lib/helpers.rb", "lib/commands/site/template/project/site/content.erb", "lib/commands/site/template/project/site/header.erb", "lib/commands/site/template/project/site/layout.erb", "lib/commands/site/template/project/site/navigation.erb", "lib/commands/site/template/project/site/variables.yml", "lib/commands/site/template/project/styles/style.sass", "lib/commands/site/template/script/config/boot.rb", "lib/commands/site/template/script/moka", "lib/script_moka_loader.rb", "lib/version.rb", "moka.gemspec"]
  s.homepage = %q{https://github.com/DukeLeNoir/Moka}
  s.post_install_message = %q{Welcome aboard Moka. You'll love it!}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Moka", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{moka}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{An damn simple static website framework.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, [">= 0"])
      s.add_runtime_dependency(%q<haml>, [">= 0"])
    else
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 0"])
    end
  else
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 0"])
  end
end
