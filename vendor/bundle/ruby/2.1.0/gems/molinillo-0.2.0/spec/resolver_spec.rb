require File.expand_path('../spec_helper', __FILE__)
require 'json'
require 'pathname'

module Molinillo
  FIXTURE_DIR = Pathname.new('spec/resolver_integration_specs')
  FIXTURE_INDEX_DIR = FIXTURE_DIR + 'index'
  FIXTURE_CASE_DIR = FIXTURE_DIR + 'case'

  class TestCase
    require File.expand_path('../spec_helper/index', __FILE__)
    require File.expand_path('../spec_helper/specification', __FILE__)
    require File.expand_path('../spec_helper/ui', __FILE__)

    attr_accessor :name, :requested, :base, :conflicts, :resolver, :result, :index

    # rubocop:disable Metrics/MethodLength
    def initialize(fixture_path)
      File.open(fixture_path) do |fixture|
        JSON.load(fixture).tap do |test_case|
          self.name = test_case['name']
          self.index = TestIndex.new(test_case['index'] || 'awesome')
          self.requested = test_case['requested'].map do |(name, reqs)|
            VersionKit::Dependency.new name, reqs.split(',').map(&:chomp)
          end
          add_dependencies_to_graph = lambda do |graph, parent, hash|
            name = hash['name']
            version = VersionKit::Version.new(hash['version'])
            dependency = index.specs[name].find { |s| s.version == version }
            node = if parent
                     graph.add_vertex(name, dependency).tap do |v|
                       graph.add_edge(parent, v, dependency)
                     end
                   else
                     graph.add_root_vertex(name, dependency)
                   end
            hash['dependencies'].each do |dep|
              add_dependencies_to_graph.call(graph, node, dep)
            end
          end
          self.result = test_case['resolved'].reduce(DependencyGraph.new) do |graph, r|
            graph.tap do |g|
              add_dependencies_to_graph.call(g, nil, r)
            end
          end
          self.base = test_case['base'].reduce(DependencyGraph.new) do |graph, r|
            graph.tap do |g|
              add_dependencies_to_graph.call(g, nil, r)
            end
          end
          self.conflicts = test_case['conflicts'].to_set
        end
      end

      self.resolver = Resolver.new(index, TestUI.new)
    end
    # rubocop:enable Metrics/MethodLength
  end

  describe Resolver do

    describe 'dependency resolution' do
      Dir.glob(FIXTURE_CASE_DIR + '**/*.json').map do |fixture|
        test_case = TestCase.new(fixture)
        it test_case.name do
          resolve = lambda { test_case.resolver.resolve(test_case.requested, test_case.base) }

          if test_case.conflicts.any?
            error = should.raise ResolverError do
              resolve.call
            end

            names = case error
                    when CircularDependencyError
                      error.dependencies.map(&:name)
                    when VersionConflict
                      error.conflicts.keys
                    end.to_set
            names.should.equal test_case.conflicts
          else
            result = resolve.call

            pretty_dependencies = lambda do |dg|
              dg.vertices.values.map { |v| "#{v.payload.name} (#{v.payload.version})" }.sort
            end
            pretty_dependencies.call(result).should.
              equal pretty_dependencies.call(test_case.result)

            result.should.equal test_case.result
          end
        end
      end
    end

    describe 'in general' do
      before do
        @resolver = Resolver.new(TestIndex.new('awesome'), TestUI.new)
      end

      it 'can resolve a list of 0 requirements' do
        @resolver.resolve([], DependencyGraph.new).
          should.equal DependencyGraph.new
      end

      it 'includes the source of a user-specified unsatisfied dependency' do
        should.raise VersionConflict do
          @resolver.resolve([VersionKit::Dependency.new('missing', '3.0')], DependencyGraph.new)
        end.message.should.match /required by `user-specified dependency`/
      end
    end

  end
end
