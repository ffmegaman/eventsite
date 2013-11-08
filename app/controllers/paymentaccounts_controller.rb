class PaymentaccountsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :oauth]
  # GET /paymentaccounts
  # GET /paymentaccounts.json
  def index
    @paymentaccounts = Paymentaccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @paymentaccounts }
    end
  end

  # GET /paymentaccounts/1
  # GET /paymentaccounts/1.json
  def show
    @paymentaccount = Paymentaccount.find(params[:id])
    @is_admin = current_user && current_user.id == @paymentaccount.user_id

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @paymentaccount }
    end
  end

  # GET /paymentaccounts/new
  # GET /paymentaccounts/new.json
  def new
    @paymentaccount = current_user.paymentaccounts.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @paymentaccount }
    end
  end

  # GET /paymentaccounts/1/edit
  def edit
    @paymentaccount = current_user.paymentaccounts.find(params[:id])
  end

  # POST /paymentaccounts
  # POST /paymentaccounts.json
  def create
    @paymentaccount = current_user.paymentaccounts.new(params[:paymentaccount])

    respond_to do |format|
      if @paymentaccount.save
        format.html { redirect_to @paymentaccount } #notice: 'Paymentaccount was successfully created.' }
        format.json { render json: @paymentaccount, status: :created, location: @paymentaccount }
      else
        format.html { render action: "new" }
        format.json { render json: @paymentaccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /paymentaccounts/1
  # PUT /paymentaccounts/1.json
  def update
    @paymentaccount = current_user.paymentaccounts.find(params[:id])

    respond_to do |format|
      if @paymentaccount.update_attributes(params[:paymentaccount])
        format.html { redirect_to @paymentaccount, notice: 'Paymentaccount was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @paymentaccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /paymentaccounts/1
  # DELETE /paymentaccounts/1.json
  def destroy
    @paymentaccount = current_user.paymentaccounts.find(params[:id])
    @paymentaccount.destroy

    respond_to do |format|
      format.html { redirect_to paymentaccounts_url }
      format.json { head :no_content }
    end
  end
  
  def pin_params
    params.require(:paymentaccount).permit(:agreement)
  end

  # GET /farmers/oauth/1
  def oauth
    if !params[:code]
      return redirect_to('/')
    end

    redirect_uri = url_for(:controller => 'paymentaccounts', :action => 'oauth', :paymentaccount_id => params[:paymentaccount_id], :host => request.host_with_port)
    @paymentaccount = Paymentaccount.find(params[:paymentaccount_id])
    begin
      @paymentaccount.request_wepay_access_token(params[:code], redirect_uri)
    rescue Exception => e
      error = e.message
    end

    if error
      redirect_to @paymentaccount, alert: error
    else
      redirect_to @paymentaccount, notice: 'We successfully connected you to WePay!'
    end
  end
end