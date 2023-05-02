class AccountTransactionsController < ApplicationController
  before_action :get_user
  before_action :get_account

  def index
    render json: { account_transactions: @account.account_transactions }, status: 200
  end

  private

  def account_transaction_params
    params.permit(:user_id, :account_id)
  end

  def get_user
    @user = User.find(account_transaction_params[:user_id])
  end

  def get_account
    @account = @user.accounts.find(account_transaction_params[:account_id])
  end
end