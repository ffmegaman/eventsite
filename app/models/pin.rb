class Pin < ActiveRecord::Base
  attr_accessible :description, :image, :image_remote_url, :event_name, :price, :wepay_access_token, :wepay_account_id


  validates :event_name, presence: true
  validates :event_name, :length => { :in => 5..120}
  validates :description, presence: true
	validates :user_id, presence: true
  validates :price, presence: true

	
	has_attached_file :image, styles: { medium: "320x240" }
	validates_attachment :image, presence: true,
																content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'] },
																size: { less_than: 5.megabytes }

  belongs_to :user
  
  def image_remote_url=(url_value)
  	self.image = URI.parse(url_value) unless url_value.blank?
  	super
  end


  # get the authorization url for this farmer. This url will let the farmer 
  # register or login to WePay to approve our app.

  # returns a url
  def wepay_authorization_url(redirect_uri)
    #Eventsite::Application::WEPAY.oauth2_authorize_url(redirect_uri, self.email, self.name)
    Eventsite::Application::WEPAY.oauth2_authorize_url(redirect_uri)
  end

  # takes a code returned by wepay oauth2 authorization and makes an api call to generate oauth2 token for this farmer.
  def request_wepay_access_token(code, redirect_uri)
    response = Eventsite::Application::WEPAY.oauth2_token(code, redirect_uri)
    if response['error']
      raise "Error - "+ response['error_description']
    elsif !response['access_token']
      raise "Error requesting access from WePay"
    else
      self.wepay_access_token = response['access_token']
      self.save
      #create WePay account
      self.create_wepay_account
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
    response = Eventsite::Application::WEPAY.call("/user", self.wepay_access_token)
    response && response["user_id"] ? true : false
  end

  def has_wepay_account?
    self.wepay_account_id != 0 && !self.wepay_account_id.nil?
  end

  # creates a WePay account for this farmer with the farm's name
  def create_wepay_account
    if self.has_wepay_access_token? && !self.has_wepay_account?
      params = { :name => self.event_name, :description => "Tickets for " + self.event_name }     
      response = Eventsite::Application::WEPAY.call("/account/create", self.wepay_access_token, params)

      if response["account_id"]
        self.wepay_account_id = response["account_id"]
        return self.save
      else
        raise "Error - " + response["error_description"]
      end

    end   
    raise "Error - cannot create WePay account"
  end
  # creates a checkout object using WePay API for this farmer
  def create_checkout(redirect_uri)
    # calculate app_fee as 4% of produce price
    app_fee = self.price * 0.04
    correct_pin = self.find(params[:id])

    params = { 
      :account_id => Paymentaccount.find_by_user_id(correct_pin.user_id).wepay_account_id, 
      :short_description => "#{self.event_name} hosted by #{user.name}",
      :type => :GOODS,
      :amount => self.price,      
      :app_fee => app_fee,
      :fee_payer => :payee,     
      :mode => :iframe,
      :redirect_uri => redirect_uri
    }
    response = Eventsite::Application::WEPAY.call('/checkout/create', self.wepay_access_token, params)

    if !response
      raise "Error - no response from WePay"
    elsif response['error']
      raise "Error - " + response["error_description"]
    end

    return response
  end

  
end
