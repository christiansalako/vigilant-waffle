require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '#lifecycle_status' do
    it 'returns :live when project is currently live' do
      project = create(:project, :live)
      expect(project.lifecycle_status).to eq(:live)
    end

    it 'returns :future when project is in the future' do
      project = create(:project, :future)
      expect(project.lifecycle_status).to eq(:future)
    end

    it 'returns :ended when project has ended' do
      project = create(:project, :ended)
      expect(project.lifecycle_status).to eq(:ended)
    end

    it 'returns :not_set when dates are not set' do
      project = create(:project, :not_set)
      expect(project.lifecycle_status).to eq(:not_set)
    end
  end

  describe '#live?' do
    it 'returns true if now is between start_date and end_date' do
      project = build(:project, :live)
      expect(project.send(:live?)).to be true
    end

    it 'returns a live project when both start and end dates fall on todays date' do
      project = create(:project, :live)

      project.update(start_date: Date.today, end_date: Date.today)

      expect(project.lifecycle_status).to eq(:live)
    end

    it 'returns false otherwise' do
      project = build(:project, :future)
      expect(project.send(:live?)).to be false
    end
  end

  describe '#future?' do
    it 'returns true if start_date is in the future' do
      project = build(:project, :future)
      expect(project.send(:future?)).to be true
    end
    it 'returns false otherwise' do
      project = build(:project, :live)
      expect(project.send(:future?)).to be false
    end
  end

  describe '#ended?' do
    it 'returns true if end_date is in the past' do
      project = build(:project, :ended)
      expect(project.send(:ended?)).to be true
    end
    it 'returns false otherwise' do
      project = build(:project, :live)
      expect(project.send(:ended?)).to be false
    end
  end
end 
