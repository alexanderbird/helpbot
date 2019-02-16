require "rails_helper"
describe Toolbox::Tools::Bible do
  it "appears in the list of tools" do
    expect(Toolbox::Tools.all).to include Toolbox::Tools::Bible
  end
  context '#will_handle' do
    [
      { matches: true, text: "bible" },
      { matches: true, text: "bible Genesis 1:1" },
      { matches: true, text: "bible Song of Songs 1:1" },
      { matches: false, text: "whatever bible Genesis 1:1" },
      { matches: false, text: " bible Genesis 1:1" },
      { matches: false, text: "bibl Genesis 1:1" },
      { matches: false, text: "bible Genesis" },
      { matches: false, text: "bible 1:1" },
      { matches: false, text: "bibl" },
      { matches: false, text: "biblee" }
    ].each do |test_data|
      matches = test_data[:matches]
      text = test_data[:text]
      it "#{matches ? 'matches' : 'does not match'} '#{text}'" do
        if(matches)
          expect(Toolbox::Tools::Bible.will_handle.match(text)).not_to be_nil
        else
          expect(Toolbox::Tools::Bible.will_handle.match(text)).to be_nil
        end
      end
    end
  end
  context '#help_text' do
    it "returns useful help text" do
      expect(Toolbox::Tools::Bible.help_text).to eq("bible [<book> <chapter and verse>]")
    end
  end
  context '#handle', vcr: true do
    it "returns the first 5 verses of the proverb of the day in response to 'bible'" do
      allow(Time.zone).to receive(:today).and_return Date.new(2012,4,11)
      result = Toolbox::Tools::Bible.new('bible').handle
      expect(result).to eq(PROVERBS_11__1_5)
    end

    it "returns Genesis 1:2-6 in response to 'bible genesis 1:2-6'" do
      result = Toolbox::Tools::Bible.new('bible genesis 1:2-6').handle
      expect(result).to eq(GENESIS_1__2_6)
    end

    it "returns only the first 5 verses if a longer passage is requested (e.g. 6 verses, Galatians 2:19-3:3)" do
      result = Toolbox::Tools::Bible.new('bible galatians 2:19-3:3').handle
      expect(result).to eq(GALATIANS_2__19___3__3)
    end

    it "returns a help message when a passage isn't found (for example, 'Foobar 23:19')" do
      result = Toolbox::Tools::Bible.new('bible foobar 23:19').handle
      expect(result).to eq('Nothing found for "foobar 23:19"')
    end

    it "returns a help message when the api isn't working" do
      # Fiddled with the VCR for this spec so it returns an error response
      result = Toolbox::Tools::Bible.new('bible genesis 1:1').handle
      expect(result).to eq("There was a problem connecting to the Bible api")
    end
  end
end

PROVERBS_11__1_5 = "A false balance is abomination to the LORD: but a just weight is his delight.

When pride cometh, then cometh shame: but with the lowly is wisdom.

The integrity of the upright shall guide them: but the perverseness of transgressors shall destroy them.

Riches profit not in the day of wrath: but righteousness delivereth from death.

The righteousness of the perfect shall direct his way: but the wicked shall fall by his own wickedness.
 — Proverbs 11:1-5".freeze

GENESIS_1__2_6 = "And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.

And God said, Let there be light: and there was light.

And God saw the light, that it was good: and God divided the light from the darkness.

And God called the light Day, and the darkness he called Night. And the evening and the morning were the first day.

And God said, Let there be a firmament in the midst of the waters, and let it divide the waters from the waters.
 — Genesis 1:2-6".freeze

GALATIANS_2__19___3__3 = "For I through the law am dead to the law, that I might live unto God.

I am crucified with Christ: nevertheless I live; yet not I, but Christ liveth in me: and the life which I now live in the flesh I live by the faith of the Son of God, who loved me, and gave himself for me.

I do not frustrate the grace of God: for if righteousness come by the law, then Christ is dead in vain.

O foolish Galatians, who hath bewitched you, that ye should not obey the truth, before whose eyes Jesus Christ hath been evidently set forth, crucified among you?

This only would I learn of you, Received ye the Spirit by the works of the law, or by the hearing of faith?
 — Galatians 2:19-3:3 (5/6 verses shown)".freeze
