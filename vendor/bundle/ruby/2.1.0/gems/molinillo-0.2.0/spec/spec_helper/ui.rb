module Molinillo
  class TestUI
    include UI

    def output
      @output ||= File.open('/dev/null', 'w')
    end
  end
end
