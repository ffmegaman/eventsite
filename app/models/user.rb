class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, #:recoverable, 
         :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  # attr_accessible :title, :body

  has_many :pins

  # get the authorization url for this user. This url will let the user 
	# register or login to WePay to approve our app.

	# returns a url
	def wepay_authorization_url(redirect_uri)
	  Wefarm::Application::WEPAY.oauth2_authorize_url(redirect_uri, self.email, self.name)
	end

	# takes a code returned by wepay oauth2 authorization and makes an api call to generate oauth2 token for this farmer.
	def request_wepay_access_token(code, redirect_uri)
	  response = Wefarm::Application::WEPAY.oauth2_token(code, redirect_uri)
	  if response['error']
	    raise "Error - "+ response['error_description']
	  elsif !response['access_token']
	    raise "Error requesting access from WePay"
	  else
	    self.wepay_access_token = response['access_token']
	    self.save
	  end
	end

	def has_wepay_access_token?
	  !self.wepay_access_token.nil?
	end

	# makes an api call to WePay to check if current access token for farmer is still valid
	def has_valid_wepay_access_token?
	  if self.wepay_access_token.nil?
	    return false
	  end
	  response = Wefarm::Application::WEPAY.call("/user", self.wepay_access_token)
	  response && response["user_id"] ? true : false
	end
end
