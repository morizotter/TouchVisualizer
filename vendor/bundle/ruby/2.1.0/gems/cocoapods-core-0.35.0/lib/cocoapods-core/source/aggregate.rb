module Pod
  class Source
    # The Aggregate manages a directory of sources repositories.
    #
    class Aggregate
      # @return [Array<Pathname>] The ordered list of source directories.
      #
      attr_reader :directories

      # @param  [Array<Pathname>] repos_dirs @see directories
      #
      def initialize(repos_dirs)
        @directories = Array(repos_dirs)
      end

      # @return [Array<Source>] The ordered list of the sources.
      #
      def sources
        @sources ||= directories.map { |repo| Source.new(repo) }
      end

      # @return [Array<String>] the names of all the pods available.
      #
      def all_pods
        sources.map(&:pods).flatten.uniq
      end

      # @return [Array<Set>] The sets for all the pods available.
      #
      # @note   Implementation detail: The sources don't cache their values
      #         because they might change in response to an update. Therefore
      #         this method to preserve performance caches the values before
      #         processing them.
      #
      def all_sets
        pods_by_source = {}
        sources.each do |source|
          pods_by_source[source] = source.pods
        end
        pods = pods_by_source.values.flatten.uniq

        pods.map do |pod|
          pod_sources = sources.select { |s| pods_by_source[s].include?(pod) }
          pod_sources = pod_sources.compact
          Specification::Set.new(pod, pod_sources)
        end
      end

      # Returns a set configured with the source which contains the highest
      # version in the aggregate.
      #
      # @param  [String] name
      #         The name of the Pod.
      #
      # @return [Set] The most representative set for the Pod with the given
      #         name.
      #
      def representative_set(name)
        representative_source = nil
        highest_version = nil
        sources.each do |source|
          source_versions = source.versions(name)
          if source_versions
            source_version = source_versions.first
            if highest_version.nil? || (highest_version < source_version)
              highest_version = source_version
              representative_source = source
            end
          end
        end
        Specification::Set.new(name, representative_source)
      end

      public

      # @!group Search
      #-----------------------------------------------------------------------#

      # @return [Set, nil] a set for a given dependency including all the
      #         {Source} that contain the Pod. If no sources containing the
      #         Pod where found it returns nil.
      #
      # @raise  If no source including the set can be found.
      #
      # @see    Source#search
      #
      def search(dependency)
        found_sources = sources.select { |s| s.search(dependency) }
        unless found_sources.empty?
          Specification::Set.new(dependency.root_name, found_sources)
        end
      end

      # @return [Array<Set>]  the sets that contain the search term.
      #
      # @raise  If no source including the set can be found.
      #
      # @todo   Clients should raise not this method.
      #
      # @see    Source#search_by_name
      #
      def search_by_name(query, full_text_search = false)
        pods_by_source = {}
        result = []
        sources.each do |s|
          source_pods = s.search_by_name(query, full_text_search)
          pods_by_source[s] = source_pods.map(&:name)
        end

        root_spec_names = pods_by_source.values.flatten.uniq
        root_spec_names.each do |pod|
          result_sources = sources.select do |source|
            pods_by_source[source].include?(pod)
          end

          result << Specification::Set.new(pod, result_sources)
        end

        if result.empty?
          extra = ', author, summary, or description' if full_text_search
          raise Informative, 'Unable to find a pod with name' \
            "#{extra} matching `#{query}'"
        end
        result
      end

      public

      # @!group Search Index
      #-----------------------------------------------------------------------#

      # Generates from scratch the search data for all the sources of the
      # aggregate. This operation can take a considerable amount of time
      # (seconds) as it needs to evaluate the most representative podspec
      # for each Pod.
      #
      # @return [Hash{String=>Hash}] The search data of every set grouped by
      #         name.
      #
      def generate_search_index
        result = {}
        all_sets.each do |set|
          result[set.name] = search_data_from_set(set)
        end
        result
      end

      # Updates inline the given search data with the information stored in all
      # the sources. The update skips the Pods for which the version of the
      # search data is the same of the highest version known to the aggregate.
      # This can lead to updates in podspecs being skipped until a new version
      # is released.
      #
      # @note   This procedure is considerably faster as it only needs to
      #         load the most representative spec of the new or updated Pods.
      #
      # @return [Hash{String=>Hash}] The search data of every set grouped by
      #         name.
      #
      def update_search_index(search_data)
        enumerated_names = []
        all_sets.each do |set|
          enumerated_names << set.name
          set_data = search_data[set.name]
          has_data = set_data && set_data['version']
          if has_data
            stored_version = Version.new(set_data['version'])
            if stored_version < set.highest_version
              search_data[set.name] = search_data_from_set(set)
            end
          else
            search_data[set.name] = search_data_from_set(set)
          end
        end

        stored_names = search_data.keys
        delted_names = stored_names - enumerated_names
        delted_names.each do |name|
          search_data.delete(name)
        end

        search_data
      end

      private

      # @!group Private helpers
      #-----------------------------------------------------------------------#

      # Returns the search related information from the most representative
      # specification of the set following keys:
      #
      #   - version
      #   - summary
      #   - description
      #   - authors
      #
      # @param  [Set] set
      #         The set for which the information is needed.
      #
      # @note   If the specification can't load an empty hash is returned and
      #         a warning is printed.
      #
      # @note   For compatibility with non Ruby clients a strings are used
      #         instead of symbols for the keys.
      #
      # @return [Hash{String=>String}] A hash with the search information.
      #
      def search_data_from_set(set)
        result = {}
        spec = set.specification
        result['version'] = spec.version.to_s
        result['summary'] = spec.summary
        result['description'] = spec.description
        result['authors'] = spec.authors.keys.sort * ', '
        result
      rescue
        CoreUI.warn "Skipping `#{set.name}` because the podspec contains " \
          'errors.'
        result
      end

      #-----------------------------------------------------------------------#
    end
  end
end
