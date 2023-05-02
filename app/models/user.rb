class User < ApplicationRecord
  has_many :accounts

  validates :email, :pin, :name, presence: true
  validates :email, uniqueness: true
end
