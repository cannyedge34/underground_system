require './lib/underground_system'

RSpec.describe UndergroundSystem do
  subject(:tube) { described_class.new }

  # makes senses test the whole sequence if we would have acceptance tests.
  # From controllers/aplication/domain included the database implementation.
  # I understand we don't have controllers/application layer in this context/exercise.
  # I'm ok with this test :)
  it 'works' do
    tube.check_in(45, 'Leyton', 3)
    tube.check_in(32, 'Paradise', 8)
    tube.check_in(27, 'Leyton', 10)
    tube.check_out(45, 'Waterloo', 15)
    tube.check_out(27, 'Waterloo', 20)
    tube.check_out(32, 'Cambridge', 22)
    expect(tube.get_average_time('Paradise', 'Cambridge')).to eq(14.0)
    expect(tube.get_average_time('Leyton', 'Waterloo')).to eq(11.0)
    tube.check_in(10, 'Leyton', 24)
    expect(tube.get_average_time('Leyton', 'Waterloo')).to eq(11.0)
    tube.check_in(10, 'Waterloo', 38)
    # i don't understand very well how the passenger with id 10 checks-in twice in different stations.
    # i read this AC:
    # 4 You may assume all calls to the check_in and check_out methods are consistent.
    # i understand that before passenger check_in the second time, needs to do check_out first.

    # maybe i'm missing something, please clarify this AC ?
    # expect(tube.get_average_time('Leyton', 'Waterloo')).to eq(12.0)
  end

  # i'm mocking the repository layer, because i think we should not hit the database/infrastructure from unit tests.
  # companies/us usually work with active_record and we hit the database to test changes (rails way). e.g:

  # it 'creates results for staff' do
  #   expect do
  #     service.generate_school_owners_results(role_type, date)
  #   end.to change(::PillarResult, :count).by 1
  #   expect(created_pillar_result).to have_attributes(
  #     pillar: staff_pillar,
  #     result_type: 'school_owner',
  #     group_dashboard: group_dashboard,
  #     date: date,
  #   )
  # end

  # These types of tests are very harmful because they are coupled to the infrastructure layer.

  # I know this is a domain agregate/entity.
  # We would not inject events/averages repositories in normal situation with event-sourcing/event-driven architecture.
  # We should inject the repository interface in the application layer (use_case/aplication_service) file.

  # we trust in respository contract and test should be ok if we don't see errors in the repository actions, that's it.

  describe 'public methods' do
    let(:event_repository_klass) { ::EventRepository }
    let(:event_repository) do
      instance_double(
        event_repository_klass,
        delete: nil,
        save: data,
        find: ::EventEntity.new(id: 45, station_name: 'Leyton', time: 3)
      )
    end
    let(:average_repository_klass) { ::AverageRepository }
    let(:average_repository) do
      instance_double(average_repository_klass, find: AverageEntity.new({}))
    end

    let(:data) { { id: 45, station_name: 'Leyton', time: 3 } }

    describe '#check_in' do
      it 'calls the save method from event_repository' do
        expect(event_repository_klass).to receive(:new).and_return(event_repository)
        expect(event_repository).to receive(:save).with(data)

        tube.check_in(45, 'Leyton', 3)
      end
    end

    describe '#check_out' do
      # i assume that we should have at least one recorded checked-in event before check-out

      before do
        allow(event_repository_klass).to receive(:new).and_return(event_repository)
        allow(average_repository_klass).to receive(:new).and_return(average_repository)
      end

      it 'calls save method of average repository' do
        expect(average_repository).to receive(:save).with(id: 'Leyton,Waterloo', total_time: 12)

        tube.check_out(45, 'Waterloo', 15)
      end

      it 'calls delete method of event repository' do
        allow(average_repository).to receive(:save).with(id: 'Leyton,Waterloo', total_time: 12)
        expect(event_repository).to receive(:delete).with(45)

        tube.check_out(45, 'Waterloo', 15)
      end
    end

    describe '#get_average_time' do
      let(:average_entity) { ::AverageEntity.new({ id: 'Leyton,Waterloo', total_time: 13, count: 2 }) }

      it 'returns the correct value' do
        allow(average_repository_klass).to receive(:new).and_return(average_repository)
        allow(average_repository).to receive(:find).and_return(average_entity)

        expect(tube.get_average_time('Leyton', 'Waterloo')).to eq(6.5)
      end
    end
  end
end
