module Toolbox
  class Toolbox
    def handle input
      toolClass = Tools.all.find {|toolClass| input.match(toolClass.will_handle) }
      (toolClass || Tools::Help).new(input).handle
    end
  end
end
