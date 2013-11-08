class RegistrationsController < Devise::RegistrationsController
  def after_sign_up_path_for(resource)
  	newpaymentaccount_path
  end
end