require 'rails_helper'

describe UsersController, type: :request do
  describe '#create' do
    let(:params) do
      {
        'email': 'tony@example.com',
        'name': 'Tony',
        'pin': 1234,
        'pin_confirmation': 1234,
      }
    end
    let(:trigger!) { post "/users", params: params }

    it 'returns a 201 status' do
      trigger!
      expect(response.status).to eq(201)
    end

    it 'returns created user' do
      trigger!

      created_user = JSON.parse(response.body)
      expect(created_user['email']).to eq('tony@example.com')
      expect(created_user['name']).to eq('Tony')
    end
  end
end