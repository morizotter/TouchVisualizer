module Pod
  class Specification
    module DSL
      # Provides warning and errors for the deprecated attributes of the DSL.
      #
      module Deprecations
        def preferred_dependency=(name)
          self.default_subspecs = [name]
          CoreUI.warn "[#{self}] `preferred_dependency` has been renamed "\
            'to `default_subspecs`.'
        end
      end
    end
  end
end
