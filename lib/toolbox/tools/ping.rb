module Toolbox
  module Tools
    class Ping < Base
      def self.will_handle
        /^ping$/
      end

      def self.help_text
        "ping"
      end

      def handle
        "pong"
      end
    end
  end
end
