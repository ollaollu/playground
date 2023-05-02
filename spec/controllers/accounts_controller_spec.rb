require 'rails_helper'

describe AccountsController, type: :request do
  describe '#index' do
    let(:account) { create(:account) }
    let(:user) { account.user }
    let(:trigger!) { get "/users/#{user.id}/accounts" }

    it 'returns a 200 status' do
      trigger!
      expect(response.status).to eq(200)
    end

    it 'returns user accounts' do
      trigger!

      account_in_list = JSON.parse(response.body)['accounts'].first
      expect(account_in_list['currency']).to eq('dollar')
      expect(account_in_list['balance']).to eq('0.0')
      expect(account_in_list['user_id']).to eq(user.id)
    end
  end

  describe '#fund' do
    let(:user) { create(:user) }
    let(:account) { create(:account, user: user) }
    let(:amount) { 10 }
    let(:params) do
      {
        'amount': amount
      }
    end
    let(:trigger!) { post "/users/#{user.id}/accounts/#{account.id}/fund", params: params }

    it 'returns a 201 status' do
      trigger!
      expect(response.status).to eq(201)
    end

    it 'funds user account balance' do
      expect(account.reload.balance).to eq(0.0)

      trigger!
      expect(account.reload.balance).to eq(amount)
    end
  end

  describe '#transfer' do
    let(:sender_account) { create(:account, balance: 100) }
    let(:sender) { sender_account.user }
    let(:recipient_account) { create(:account) }
    let(:amount) { 10 }
    let(:pin) { 1234 }
    let(:params) do
      {
        "recipient_id": recipient_account.user_id,
        "pin": pin,
        "amount": amount
      }
    end
    let(:trigger!) { post "/users/#{sender.id}/accounts/#{sender_account.id}/transfer", params: params }

    it 'returns a 201 status' do
      trigger!
      expect(response.status).to eq(201)
    end

    it 'debits sender balance' do
      trigger!
      expect(sender_account.reload.balance).to eq(100 - amount)
    end

    it 'credits recipient balance' do
      trigger!
      expect(recipient_account.reload.balance).to eq(amount)
    end

    context 'when balance is not sufficient for transfer' do
      before do
        sender_account.update!(balance: 1)
      end

      it 'returns a 422 status with insufficient balance message' do
        trigger!
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors']).to eq('insufficient balance')
      end
    end

    context 'when incorrect pin is provided' do
      let(:pin) { 3456 }

      it 'returns a 422 status' do
        trigger!
        expect(response.status).to eq(422)
      end

      it 'does not debit sender balance' do
        trigger!
        expect(sender_account.reload.balance).to eq(100)
      end
  
      it 'does not credit recipient balance' do
        trigger!
        expect(recipient_account.reload.balance).to eq(0.0)
      end
    end
  end
end