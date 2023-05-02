class AccountCreationJob < ApplicationJob
  queue_as :default

  def perform(user_id, account_type)
    user = User.find_by_id(user_id)
    
    if user
      return if user.accounts.find_by_currency(account_type)
      user.accounts.create!(currency: account_type) 
    end
  end
end
