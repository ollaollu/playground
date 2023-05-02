class AccountTransaction < ApplicationRecord
  belongs_to :account

  validates :status, :transaction_type, :direction, presence: true
end
