module Pod
  class Specification
    class Set
      # The statistics class provides information about one or more {Set} that
      # is not readily available because expensive to compute or provided by a
      # remote source.
      #
      # The class provides also facilities to work with a collection of sets.
      # It always caches in memory the computed values and it can take an
      # optional path to cache file that it is responsible of populating and
      # invalidating.
      #
      # To reuse the in memory cache and to minimize the disk access to the
      # cache file a shared instance is also available.
      #
      class Statistics
        # @return [Statistics] the shared statistics instance.
        #
        def self.instance
          @instance ||= new
        end

        # Allows to set the shared instance.
        #
        # @param  [Statistics] instance
        #         the new shared instance or nil.
        #
        # @return [Statistics] the shared statistics instance.
        #
        class << self
          attr_writer :instance
        end

        # @return [Pathname] the path to the optional cache file.
        #
        # @note   The cache file can be specified after initialization, but
        #         it has to be configured before requiring any value, otherwise
        #         it is ignored.
        #
        attr_accessor :cache_file

        # @return [Integer] the number of seconds after which the caches of
        #         values that might changed are discarded.
        #
        # @note   If not specified on initialization defaults to 3 days.
        #
        attr_accessor :cache_expiration

        # @param  [Pathname] cache_file       @see cache_file
        #
        # @param  [Integer] cache_expiration  @see cache_expiration
        #
        def initialize(cache_file = nil, cache_expiration = (60 * 60 * 24 * 3))
          require 'yaml'

          @cache_file       = cache_file
          @cache_expiration = cache_expiration
        end

        #---------------------------------------------------------------------#

        # @!group Accessing the statistics

        # Computes the date in which the first podspec of a set was committed
        # on its git source.
        #
        # @param  [Set] set
        #         the set for the Pod whose creation date is needed.
        #
        # @note   The set should be generated with only the source that is
        #         analyzed. If there are more than one the first one is
        #         processed.
        #
        # @note   This method needs to traverse the git history of the repo and
        #         thus incurs in a performance hit.
        #
        # @return [Time] the date in which a Pod appeared for the first time on
        #         the {Source}.
        #
        def creation_date(set)
          date = compute_creation_date(set)
          save_cache
          date
        end

        # Computes the date in which the first podspec of each given set was
        # committed on its git source.
        #
        # @param  [Array<Set>] sets
        #         the list of the sets for the Pods whose creation date is
        #         needed.
        #
        # @note   @see creation_date
        #
        # @note   This method is optimized for multiple sets because it saves
        #         the cache file only once.
        #
        # @return [Array<Time>] the list of the dates in which the Pods
        #         appeared for the first time on the {Source}.
        #
        def creation_dates(sets)
          dates = {}
          sets.each { |set| dates[set.name] = compute_creation_date(set) }
          save_cache
          dates
        end

        # Computes the number of likes that a Pod has on Github.
        #
        # @param  [Set] set
        #         the set of the Pod.
        #
        # @return [Integer] the number of likes or nil if the Pod is not hosted
        #         on GitHub.
        #
        def github_watchers(set)
          github_stats_if_needed(set)
          get_value(set, :gh_watchers)
        end

        # Computes the number of forks that a Pod has on Github.
        #
        # @param  [Set] set @see github_watchers
        #
        # @return [Integer] the number of forks or nil if the Pod is not hosted
        #         on GitHub.
        #
        def github_forks(set)
          github_stats_if_needed(set)
          get_value(set, :gh_forks)
        end

        # Computes the number of likes that a Pod has on Github.
        #
        # @param  [Set] set @see github_watchers
        #
        # @return [Time] the time of the last push or nil if the Pod is not
        #         hosted on GitHub.
        #
        def github_pushed_at(set)
          github_stats_if_needed(set)
          string_time = get_value(set, :pushed_at)
          Time.parse(string_time) if string_time
        end

        #---------------------------------------------------------------------#

        private

        # @return [Hash{String => Hash}] the in-memory cache, where for each
        #         set is stored a hash with the result of the computations.
        #
        def cache
          unless @cache
            if cache_file && cache_file.exist?
              @cache = YAMLHelper.load_string(cache_file.read)
            else
              @cache = {}
            end
          end
          @cache
        end

        # Returns the value for the given key of a set stored in the cache, if
        # available.
        #
        # @param  [Set] set
        #         the set for which the value is needed.
        #
        # @param  [Symbol] key
        #         the key of the value.
        #
        # @return [Object] the value or nil.
        #
        def get_value(set, key)
          if cache[set.name] && cache[set.name][key]
            cache[set.name][key]
          end
        end

        # Stores the given value of a set for the given key in the cache.
        #
        # @param  [Set] set
        #         the set for which the value has to be stored.
        #
        # @param  [Symbol] key
        #         the key of the value.
        #
        # @param  [Object] value
        #         the value to store.
        #
        # @return [Object] the value or nil.
        #
        def set_value(set, key, value)
          cache[set.name] ||= {}
          cache[set.name][key] = value
        end

        # Saves the in-memory cache to the path of cache file if specified.
        #
        # @return [void]
        #
        def save_cache
          if cache_file
            yaml = YAML.dump(cache)
            File.open(cache_file, 'w') { |f| f.write(yaml) }
          end
        end

        # Analyzes the history of the git repository of the {Source} of the
        # given {Set} to find when its folder was created.
        #
        # @param  [Set] set
        #         the set for which the creation date is needed.
        #
        # @return [Time] the date in which a Pod was created.
        #
        def compute_creation_date(set)
          date = get_value(set, :creation_date)
          unless date
            Dir.chdir(set.sources.first.repo) do
              git_log = `git log --first-parent --format=%ct "#{set.name}"`
              creation_date = git_log.split("\n").last.to_i
              date = Time.at(creation_date)
            end
            set_value(set, :creation_date, date)
          end
          date
        end

        # Retrieved the GitHub information from the API for the given set and
        # stores it in the in-memory cache.
        #
        # @note   If there is a valid cache and it was generated withing the
        #         expiration time frame this method does nothing.
        #
        # @param  [Set] set
        #         the set for which the GitHub information is needed.
        #
        # @return [void]
        #
        def github_stats_if_needed(set)
          update_date = get_value(set, :gh_date)
          return if update_date && update_date > (Time.now - cache_expiration)

          spec = set.specification
          url = spec.source[:git]
          repo = GitHub.repo(url) if url

          if repo
            set_value(set, :gh_watchers, repo['watchers'])
            set_value(set, :gh_forks,    repo['forks'])
            set_value(set, :pushed_at,   repo['pushed_at'])
            set_value(set, :gh_date,     Time.now)
            save_cache
          end
        end

        #---------------------------------------------------------------------#
      end
    end
  end
end
