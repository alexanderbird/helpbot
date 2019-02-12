module Toolbox
  module Tools
    class Help < Base
      def self.will_handle
        /^help$/ 
      end

      def self.help_text
        "help"
      end

      def handle
        commands = Tools.all.map {|c| c.help_text}
        commands += [
          :logout
        ]
        commands.map {|command| "☞ #{command}"}.join("\n")
      end
    end
  end
end
