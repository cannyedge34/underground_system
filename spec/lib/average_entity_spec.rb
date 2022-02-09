require './lib/average_entity'

RSpec.describe AverageEntity do
  subject(:entity) { described_class.new(args) }

  let(:args) do
    {
      id: 'Leyton,Waterloo',
      total_time: 25,
      count: 2
    }
  end

  describe '#average_time' do
    it 'returns the average_time' do
      expect(entity.average_time).to eq(12.5)
    end
  end
end
