FactoryBot.define do
  factory :account do
    user { create(:user) }
  end
end