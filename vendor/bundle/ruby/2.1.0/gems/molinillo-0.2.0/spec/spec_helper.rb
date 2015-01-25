
# Set up coverage analysis
#-----------------------------------------------------------------------------#

if (ENV['CI'] || ENV['GENERATE_COVERAGE']) && RUBY_VERSION >= '2.0.0'
  require 'simplecov'
  require 'codeclimate-test-reporter'

  if ENV['CI']
    SimpleCov.formatter = CodeClimate::TestReporter::Formatter
  elsif ENV['GENERATE_COVERAGE']
    SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  end
  SimpleCov.start do
    add_filter '/vendor/'
    add_filter '/lib/molinillo/modules/'
  end
  CodeClimate::TestReporter.start
end

# Set up
#-----------------------------------------------------------------------------#

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
$LOAD_PATH.unshift((ROOT + 'spec').to_s)

require 'bundler/setup'
require 'bacon'
require 'mocha-on-bacon'
require 'pretty_bacon'
require 'version_kit'
require 'molinillo'
