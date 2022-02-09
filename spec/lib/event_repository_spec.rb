require './lib/event_repository'

RSpec.describe EventRepository do
  subject(:repository) { described_class.new }

  # here (repository layer) yes, we want to hit the database, we don't want to mock the client
  # we want to reproduce in these test cases (real project) casuistry derived from using this real infrastructure.
  # e.g, we want to save in mysql to know if the utf configuration is ok or not. We don't want to mock
  # the mysql client to hide these kind of bugs, because they would be in production.

  let(:data) { { id: 45, station_name: 'Leyton', time: 3 } }

  context 'with in memory implementation' do
    describe '#save' do
      it 'returns a new instance of event entity' do
        expect(repository.save(data)).to be_kind_of(EventEntity)
      end

      it 'saves a new record in database' do
        expect { repository.save(data) }.to change { repository.all.size }.from(0).to(1)
      end

      it 'has the correct data' do
        entity = repository.save(data)
        expect(entity).to have_attributes(
          id: 45,
          station_name: 'Leyton',
          time: 3
        )
      end
    end

    describe '#find' do
      context 'with no existing event' do
        let(:null_entity) { repository.find(45) }

        it 'returns null event entity' do
          expect(null_entity).to have_attributes(
            id: nil,
            station_name: nil,
            time: nil
          )
        end
      end

      context 'with existing event' do
        before do
          repository.save(data)
        end

        let(:active_entity) { repository.find(45) }

        it 'returns an existing/active event entity' do
          expect(active_entity).to have_attributes(
            id: 45,
            station_name: 'Leyton',
            time: 3
          )
        end
      end
    end

    describe '#delete' do
      before do
        repository.save(data)
      end

      it 'deletes record from database' do
        expect { repository.delete(data[:id]) }.to change { repository.all.size }.from(1).to(0)
      end
    end

    describe '#all' do
      # TO DO
    end
  end
end
