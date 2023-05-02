class BalanceService
  class << self
    def fund(user_id, account_id, amount)
      account = Account.find_by_id(account_id)

      raise Exceptions::DigiError, 'account is invalid' unless account
      raise Exceptions::DigiError, 'account does not belong to user' unless user_id == account.user_id
      raise Exceptions::DigiError, 'amount is required' unless amount
      raise Exceptions::DigiError, 'amount must be greater than 0' if amount <= 0.0 
  
      ActiveRecord::Base.transaction do
        account.lock!
        new_balance = account.balance + amount
  
        account.update!(balance: new_balance)
        account.account_transactions.create!(
          amount: amount,
          transaction_type: 'funding',
          direction: 'credit',
          status: 'success'
        )
      end
    end

    def transfer(sender_id, sender_account_id, recipient_id, amount, pin)
      raise Exceptions::DigiError, 'recipient_id is required' unless recipient_id
      raise Exceptions::DigiError, 'pin is required' unless pin
      raise Exceptions::DigiError, 'amount must be greater than 0' if amount <= 0.0

      validate_sender_information!(sender_id, sender_account_id)
      validate_recipient_information!(recipient_id)
      validate_pin!(pin)
      initiate_transfer!(amount)
    end

    private

    def validate_sender_information!(sender_id, sender_account_id)
      @sender = User.find_by_id(sender_id)
      raise Exceptions::DigiError, 'sender does not exist' unless @sender

      @sender_account = Account.find_by_id(sender_account_id)
      raise Exceptions::DigiError, 'account is invalid' unless @sender_account
      raise Exceptions::DigiError, 'account does not belong to user' unless sender_id == @sender_account.user_id
    end

    def validate_recipient_information!(recipient_id)
      @recipient = User.find_by_id(recipient_id)
      raise Exceptions::DigiError, 'recipient does not exist' unless @recipient

      @recipient_account = @recipient.accounts.find_by(currency: @sender_account.currency)
      raise Exceptions::DigiError, 'recipient cannot accept this transfer at this time' unless @recipient_account
    end

    def validate_pin!(pin)
      unless ActiveSupport::SecurityUtils.secure_compare(@sender.pin, Digest::SHA256.hexdigest(pin.to_s))
        raise Exceptions::DigiError, 'incorrect pin'
      end
    end

    def initiate_transfer!(amount)
      ActiveRecord::Base.transaction do
        @sender_account.lock!
        @recipient_account.lock!
        new_balance = @sender_account.balance - amount
        new_recipient_balance = @recipient_account.balance + amount

        raise Exceptions::DigiError, 'insufficient balance' if new_balance <= 0.0

        @sender_account.update!(balance: new_balance)
        @sender_account.account_transactions.create!(
          amount: amount,
          transaction_type: 'transfer',
          direction: 'debit',
          status: 'success'
        )

        @recipient_account.update!(balance: new_recipient_balance)
        @recipient_account.account_transactions.create!(
          amount: amount,
          transaction_type: 'transfer',
          direction: 'credit',
          status: 'success'
        )
      end
    end
  end
end