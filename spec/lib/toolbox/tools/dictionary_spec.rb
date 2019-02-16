require "rails_helper"
describe Toolbox::Tools::Dictionary do
  it "appears in the list of tools" do
    expect(Toolbox::Tools.all).to include Toolbox::Tools::Dictionary
  end
  context '#will_handle' do
    [
      { matches: true, text: "define sauce" },
      { matches: true, text: "define pasta sauce" },
      { matches: false, text: "define" },
      { matches: false, text: "sauce" }
    ].each do |test_data|
      matches = test_data[:matches]
      text = test_data[:text]
      it "#{matches ? 'matches' : 'does not match'} '#{text}'" do
        if(matches)
          expect(Toolbox::Tools::Dictionary.will_handle.match(text)).not_to be_nil
        else
          expect(Toolbox::Tools::Dictionary.will_handle.match(text)).to be_nil
        end
      end
    end
  end
  context '#help_text' do
    it "returns useful help text" do
      expect(Toolbox::Tools::Dictionary.help_text).to eq("define <word>")
    end
  end
  context '#handle', vcr: true do
    it "returns the definition of a word with its domain" do
      result = Toolbox::Tools::Dictionary.new('define uranium').handle
      expect(result).to eq(URANIUM_DEFINITION)
    end

    it "returns multiple definitions in a numbered list, and includes domains when they exist" do
      result = Toolbox::Tools::Dictionary.new('define sound').handle
      expect(result).to eq(SOUND_DEFINITION)
    end

    it "suggests a root word if the word is not found and is an inflection" do
      result = Toolbox::Tools::Dictionary.new('define reversing').handle
      expect(result).to eq(REVERSING_INFLECTION)
    end

    it "suggests an alternate spelling if the word is not found and is not an inflection" do
      result = Toolbox::Tools::Dictionary.new('define absolout').handle
      expect(result).to eq(ABSOLOUT_ALTERNATIVES)
    end

    it "returns a help message if a word is not found and it is not an inflexion and has no alternate spellings" do
      result = Toolbox::Tools::Dictionary.new('define sdffdsdsfa').handle
      expect(result).to eq(WORD_NOT_FOUND_MESSAGE)
    end

    it "returns a help message if the API is offline" do
      # Fiddled with the VCR for this spec so it returns an error response
      result = Toolbox::Tools::Dictionary.new('define offline').handle
      expect(result).to eq("There was a problem connecting to the dictionary api")
    end
  end
end

REVERSING_INFLECTION = "Did you mean
 - reverse".freeze

ABSOLOUT_ALTERNATIVES = "Did you mean
 - absonous
 - absolute".freeze

WORD_NOT_FOUND_MESSAGE = "🤦 Wow, that's not even close to a real word.".freeze

URANIUM_DEFINITION = "NOUN
Element: the chemical element of atomic number 92, a dense grey radioactive metal used as a fuel in nuclear reactors.".freeze

SOUND_DEFINITION = "NOUN
1. a) Physics: vibrations that travel through the air or another medium and can be heard when they reach a person's or animal's ear

1. b) Music: sound produced by continuous and regular vibrations, as opposed to noise.

1. c) Film, Video: music, speech, and sound effects when recorded and used to accompany a film, video, or broadcast

1. d) An idea or impression conveyed by words

2. Surgery: a long surgical probe, typically with a curved, blunt end.

3. Geography: a narrow stretch of water forming an inlet or connecting two wider areas of water such as two seas or a sea and a lake.

VERB
1. a) Emit or cause to emit sound

1. b) Convey a specified impression when heard

2. a) Nautical: ascertain (the depth of water in the sea, a lake, or a river), typically by means of a line or pole or using sound echoes

2. b) Question (someone) discreetly or cautiously so as to ascertain their opinions on a subject

2. c) Medicine: examine (a person's bladder or other internal cavity) with a long surgical probe.

2. d) Zoology: (especially of a whale) dive down steeply to a great depth

ADJECTIVE
1. a) In good condition; not damaged, injured, or diseased

1. b) Based on valid reason or good judgement

1. c) (of sleep) deep and undisturbed

1. d) (of a beating) severe

ADVERB
1. Soundly".freeze
