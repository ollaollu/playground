class Account < ApplicationRecord
  belongs_to :user
  has_many :account_transactions

  validates :currency, uniqueness: { scope: :user_id }
end
