# frozen_string_literal: true

require_relative '../../tests/test_management'
describe 'Status Smoke' do
  before do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new status' do
    it 'check creating new status' do
      name = rand_status_name
      status = @user.create_new_status(name:)
      expect(status.errors).to be_empty
      expect(status.name).to eq(name)
      expect(status.color).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end

    it 'check creating new status with color' do
      name = rand_status_name
      status = @user.create_new_status(name:, color: '#aaccbb')
      expect(status.response.code).to eq('200')
      expect(status.errors).to be_empty
      expect(status.name).to eq(name)
      expect(status.color).to eq('#aaccbb')
    end

    it 'check creating new status if it has created later' do
      name = rand_status_name
      color = '#aaccbb'
      first_status = @user.create_new_status(name:, color:)
      second_status = @user.create_new_status(name:, color:)
      expect(first_status.response.code).to eq('200')
      expect(second_status.response.code).to eq('200')
      expect(first_status.id).to eq(second_status.id)
    end

    it 'check block new status' do
      name = rand_status_name
      status = @user.create_new_status(name:)
      status_new = @user.status_edit(id: status.id, block: true)
      expect(status_new.block).to be_truthy
      expect(status_new.id).to eq(status.id)
      expect(status_new.errors).to be_empty
    end

    it 'check unblock new status' do
      name = rand_status_name
      status = @user.create_new_status(name:)
      @user.status_edit(id: status.id, block: true)
      status_new = @user.status_edit(id: status.id, block: false)
      expect(status_new.block).to be_falsey
      expect(status_new.id).to eq(status.id)
      expect(status_new.errors).to be_empty
    end

    it 'check change name of status' do
      name = rand_status_name
      new_name = rand_status_name
      status = @user.create_new_status(name:)
      status_new = @user.status_edit(id: status.id, name: new_name)
      expect(status_new.response.code).to eq('200')
      expect(status_new.errors).to be_empty
      expect(status_new.name).to eq(new_name)
      expect(status_new.block).to be_falsey
    end
  end

  describe 'Statuses get all' do
    it 'check get all statuses after create' do
      status = @user.create_new_status
      statuses_pack = @user.get_all_statuses
      expect(statuses_pack).to be_contain(status)
    end

    it 'check get not blocked statuses after create' do
      status_not_blocked = @user.create_new_status
      status = @user.create_new_status
      status = @user.status_edit(id: status.id, block: true)
      statuses = @user.get_not_blocked_statuses
      expect(statuses).to be_contain(status_not_blocked)
      expect(statuses).not_to be_contain(status)
    end
  end
end
