require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet/version'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f < 3.6
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

Rake::Task[:lint].clear

PuppetLint.configuration.relative = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
# disable selectors in resource warnings:
PuppetLint.configuration.send('disable_selector_inside_resource')

#### WARNING: questionable checks:
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_nested_classes_or_defines')
PuppetLint.configuration.send('disable_autoloader_layout')

# https://github.com/relud/puppet-lint-strict_indent-check#alternate-indentation
PuppetLint.configuration.chars_per_indent = ENV['PUPPET_LINT_CHARS_PER_INDENT'] || 2

exclude_paths = [
  "bundle/**/*",
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc "Populate CONTRIBUTORS file"
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

task :metadata do
  sh "metadata-json-lint metadata.json"
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
  :metadata,
]

desc 'Update module from puppet-module-skeleton'
task :update_from_skeleton, :safe_update do |t,args|

  args.with_defaults(:safe_update => false)
  safe_update = args[:safe_update]

  require 'erb'
  require 'json'

  require 'ostruct'
  metadata = {}
  metadata = OpenStruct.new(metadata)

  static_files = [
    'Gemfile',
    'Rakefile',
    'jenkins.sh',
    '.gitignore',
    'spec/spec_helper.rb',
    'spec/acceptance/nodesets/default.yml',
    'spec/acceptance/nodesets/centos6.yml',
    'spec/acceptance/nodesets/centos7.yml',
    'spec/acceptance/nodesets/vagrant-centos6.yml',
    'spec/acceptance/nodesets/vagrant-centos7.yml',
  ]

  templates = [
    '.fixtures.yml.erb',
    'Puppetfile.erb.erb',
    'metadata.json.erb',
    'spec/classes/example_spec.rb.erb',
    'spec/spec_helper_acceptance.rb.erb',
    'README.markdown.erb',
  ]

  if safe_update
    protected_files = [
      '.fixtures.yml.erb',
      'metadata.json.erb',
      'spec/classes/example_spec.rb.erb',
      'README.markdown.erb',
    ]
    static_files = static_files - protected_files
    templates = templates - protected_files
  end

  skeleton_dir = File.join( File.expand_path('~'), '.puppet/var/puppet-module/skeleton')

  metadata_file = File.join(Dir.getwd, "metadata.json")

  metadata_hash = {}

  File.open( metadata_file, "r" ) do |f|
    metadata_hash = JSON.load( f )
  end

  repo_name = metadata_hash['name']

  if repo_name =~ /^(|puppetmodule-)/
    repo_name.gsub!(/^puppetmodule-/, 'puppet-module-')
    File.open( metadata_file ,"w" ) do |f|
      metadata_hash['name'] = repo_name
      f.write(JSON.pretty_generate metadata_hash)
    end
  end

  metadata.name = repo_name.split(/puppet-module-/)[1]
  metadata.author = 'me'
  metadata.license = 'Apache 2.0'

  static_files.each do |f|
    skeleton_file =  File.join( skeleton_dir, f)
    FileUtils.cp skeleton_file, File.join(Dir.getwd, f) if File.exists?(skeleton_file)
  end

  templates.each do |t|
    template = ERB.new( File.read(File.join( skeleton_dir, t)), 0, '<>' )
    tmp_target = Tempfile.new(File.basename(t))
    tmp_target.write template.result(binding)
    tmp_target.rewind
    target_file = File.join(Dir.getwd, File.join(File.dirname(t),File.basename(t, '.erb')))
    FileUtils.cp tmp_target, target_file
  end

end
