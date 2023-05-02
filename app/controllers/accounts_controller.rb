class AccountsController < ApplicationController
  before_action :get_user
  before_action :get_account

  def index
    render json: { accounts: @user.accounts }, status: 200
  end

  def fund
    ::BalanceService.fund(@user.id, @account.id, amount_due)

    render json: { account: @account, message: 'Success!' }, status: 201
  end

  def transfer
    ::BalanceService.transfer(@user.id, @account.id, transfer_params[:recipient_id], amount_due, transfer_params[:pin])
    
    render json: { account: @account, message: "Transfer successful!" }, status: 201
  end

  private

  def get_user
    @user = User.find(account_params[:user_id])
  end

  def get_account
    @account = @user.accounts.find(account_params[:user_id])
  end

  def account_params
    params.permit(:user_id)
  end

  def transfer_params
    params.permit(:user_id, :account_id, :recipient_id, :amount, :pin)
  end

  def amount_due
    transfer_params[:amount].to_d
  end
end