require "rails_helper"
describe Toolbox::Tools::Bible do
  context '#will_handle' do
  end
  context '#help_text' do
  end
  context '#handle' do
    it 'returns the first 5 verses of the proverb of the day in response to "proverb of the day"', :vcr do
      result = Toolbox::Tools::Bible.new('proverb of the day').handle
      expect(result).to eq("
        lorem ipsum
      ")
    end
  end
end
