module Toolbox
  class Toolbox
    def handle raw_input
      input = raw_input.downcase 
      toolClass = Tools.all.find {|toolClass| input.match(toolClass.will_handle) }
      (toolClass || Tools::Help).new(input).handle
    end
  end
end
