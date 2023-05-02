class UsersController < ApplicationController
  def create
    validate_pin!

    ActiveRecord::Base.transaction do
      @user = User.create!(
        email: user_params[:email],
        pin: Digest::SHA256.hexdigest(user_params[:pin].to_s),
        name: user_params[:name]
      )
  
      AccountCreationJob.perform_later(@user.id, 'dollar')
    end

    render json: { id: @user.id, email: @user.email, name: @user.name }, status: 201
  end

  private

  def user_params
    params.permit(:email, :pin, :pin_confirmation, :name)
  end

  def validate_pin!
    raise Exceptions::DigiError, 'pin is required' unless user_params[:pin]
    raise Exceptions::DigiError, 'pin_confirmation is required' unless user_params[:pin_confirmation]

    if (user_params[:pin] != user_params[:pin_confirmation])
      raise Exceptions::DigiError, 'pin does not match'
    end
  end
end