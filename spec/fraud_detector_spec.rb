require 'fraud_detector'

describe 'FraudDetector' do
  let(:fraudulent) { FraudDetector.new('smith', 'SW12 4SL', 2901, '06/24') }
  let(:not_fraudulent) { FraudDetector.new('nicholls', 'E20 2SS', 3429, '1/21') }
  let(:card_digits) { FraudDetector.new('davidson', 'SE10 9CS', 2362, '3/2022') }

  describe '#fraudulent?' do
    it 'Should return true' do
      actual = fraudulent.fraudulent?
      expect(actual).to be(true)
    end

    it 'Should return false' do
      actual = not_fraudulent.fraudulent?
      expect(actual).to be(false)
    end
  end

  describe '#initialize' do
    it '@postcode should contain no spaces' do
      expect(fraudulent.postcode.include?(' ')).to be(false)
    end
  end
end
