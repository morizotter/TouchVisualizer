require File.expand_path('../spec_helper', __FILE__)
require 'set'

module Molinillo
  describe DependencyGraph do
    describe 'in general' do
      before do
        @graph = DependencyGraph.new
        @root  = @graph.add_root_vertex('Root', 'Root')
        @root2 = @graph.add_root_vertex('Root2', 'Root2')
        @child = @graph.add_child_vertex('Child', 'Child', %w(Root), 'Child')
      end

      it 'returns root vertices by name' do
        @graph.root_vertex_named('Root').
          should.equal @root
      end

      it 'returns vertices by name' do
        @graph.vertex_named('Root').
          should.equal @root
        @graph.vertex_named('Child').
          should.equal @child
      end

      it 'returns nil for non-existant root vertices' do
        @graph.root_vertex_named('missing').
          should.equal nil
      end

      it 'returns nil for non-existant vertices' do
        @graph.vertex_named('missing').
          should.equal nil
      end
    end

    describe 'detaching a node' do
      before do
        @graph = DependencyGraph.new
      end

      it 'detaches a root vertex without successors' do
        root = @graph.add_root_vertex('root', 'root')
        @graph.detach_vertex_named(root.name)
        @graph.vertex_named(root.name).
          should.equal nil
        @graph.vertices.count.
          should.equal 0
      end

      it 'detaches a root vertex with successors' do
        root = @graph.add_root_vertex('root', 'root')
        child = @graph.add_child_vertex('child', 'child', %w(root), 'child')
        @graph.detach_vertex_named(root.name)
        @graph.vertex_named(root.name).
          should.equal nil
        @graph.vertex_named(child.name).
          should.equal nil
        @graph.vertices.count.
          should.equal 0
      end

      it 'detaches a root vertex with successors with other parents' do
        root = @graph.add_root_vertex('root', 'root')
        root2 = @graph.add_root_vertex('root2', 'root2')
        child = @graph.add_child_vertex('child', 'child', %w(root root2), 'child')
        @graph.detach_vertex_named(root.name)
        @graph.vertex_named(root.name).
          should.equal nil
        @graph.vertex_named(child.name).
          should.equal child
        child.predecessors.
          should.equal Set[root2]
        @graph.vertices.count.
          should.equal 2
      end
    end
  end
end
