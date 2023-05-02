require 'rails_helper'

describe AccountsController, type: :request do
  describe '#index' do
    let(:account) { create(:account) }
    let(:user) { account.user }
    let(:trigger!) { get "/users/#{user.id}/accounts/#{account.id}/account_transactions" }

    before do
      ::BalanceService.fund(user.id, account.id, 10)
    end

    it 'returns a 200 status' do
      trigger!
      expect(response.status).to eq(200)
    end

    it 'returns user account transactions' do
      trigger!

      transaction_in_list = JSON.parse(response.body)['account_transactions'].first
      expect(transaction_in_list['amount']).to eq('10.0')
      expect(transaction_in_list['direction']).to eq('credit')
      expect(transaction_in_list['account_id']).to eq(account.id)
      expect(transaction_in_list['status']).to eq('success')
      expect(transaction_in_list['transaction_type']).to eq('funding')
    end
  end
end