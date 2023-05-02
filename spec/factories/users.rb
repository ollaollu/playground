FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    pin { Digest::SHA256.hexdigest('1234') }
    name { Faker::Name.first_name }
  end
end