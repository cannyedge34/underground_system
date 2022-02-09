require './lib/average_repository'

RSpec.describe AverageRepository do
  subject(:repository) { described_class.new }

  let(:data) { { id: 'Leyton,Waterloo', total_time: 12 } }

  context 'with in memory implementation' do
    describe '#save' do
      context 'with non-existing record in the database' do
        it 'returns an instance of average entity' do
          expect(repository.save(data)).to be_kind_of(AverageEntity)
        end

        it 'saves a new record in database' do
          expect { repository.save(data) }.to change { repository.all.size }.from(0).to(1)
        end

        it 'has the correct data' do
          entity = repository.save(data)
          expect(entity).to have_attributes(
            id: 'Leyton,Waterloo',
            total_time: 12,
            count: 1
          )
        end
      end

      context 'with existing record in the database' do
        before do
          repository.save(data)
        end

        let(:updated_data) { { id: 'Leyton,Waterloo', total_time: 20 } }

        it 'returns an instance of average entity' do
          expect(repository.save(data)).to be_kind_of(AverageEntity)
        end

        it 'does not add more records to database' do
          expect { repository.save(data) }.not_to change(repository.all, :size)
        end

        it 'updates the existing record' do
          expect(repository.all.first.count).to eq(1)
          expect(repository.all.first.total_time).to eq(12)

          repository.save(updated_data)

          expect(repository.all.first.count).to eq(2)
          expect(repository.all.first.total_time).to eq(32)
        end
      end
    end

    describe '#find' do
      context 'with no existing average' do
        let(:null_entity) { repository.find(45) }

        it 'returns null average entity' do
          expect(null_entity).to have_attributes(
            id: nil,
            total_time: nil,
            count: 1
          )
        end
      end

      context 'with existing average' do
        before do
          repository.save(data)
        end

        let(:active_entity) { repository.find('Leyton,Waterloo') }

        it 'returns an existing/active average entity' do
          expect(active_entity).to have_attributes(
            id: 'Leyton,Waterloo',
            total_time: 12,
            count: 1
          )
        end
      end
    end

    describe '#all' do
      # TO DO
    end

    describe '#create' do
      # TO DO
    end

    describe '#update' do
      # TO DO
    end
  end
end
