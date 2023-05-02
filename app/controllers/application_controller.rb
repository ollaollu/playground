class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid do |exception|
    render json: { errors: exception.to_s }, status: 422
  end
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { errors: exception.to_s }, status: 404
  end

  rescue_from Exceptions::DigiError do |exception|
    render json: { errors: exception.to_s }, status: 422
  end
end
