# Bootstrap
#-----------------------------------------------------------------------------#

task :bootstrap do
  if system('which bundle')
    sh 'bundle install'
  else
    $stderr.puts "\033[0;31m" \
      "[!] Please install the bundler gem manually:\n" \
      '    $ [sudo] gem install bundler' \
      "\e[0m"
    exit 1
  end
end

begin

  require 'bundler/gem_tasks'

  task :default => 'spec'

  # Spec
  #-----------------------------------------------------------------------------#

  desc 'Runs all the specs'
  task :spec do
    start_time = Time.now
    sh "bundle exec bacon #{specs('**')}"
    duration = Time.now - start_time
    puts "Tests completed in #{duration}s"
    Rake::Task['rubocop'].invoke
  end

  def specs(dir)
    FileList["spec/#{dir}/*_spec.rb"].shuffle.join(' ')
  end

  # Rubocop
  #-----------------------------------------------------------------------------#

  desc 'Checks code style'
  task :rubocop do
    require 'rubocop'
    cli = RuboCop::CLI.new
    result = cli.run(FileList['{spec,lib}/**/*.rb'])
    abort('RuboCop failed!') unless result == 0
  end

rescue LoadError
  $stderr.puts "\033[0;31m" \
    '[!] Some Rake tasks haven been disabled because the environment' \
    ' couldn’t be loaded. Be sure to run `rake bootstrap` first.' \
    "\e[0m"
end
