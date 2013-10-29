class PinsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :oauth, :buy, :payment_success]



  # GET /pins
  # GET /pins.json
  def index
    @pins = Pin.order("created_at desc").page(params[:page]).per_page(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pins }
      format.js
    end
  end

  # GET /pins/1
  # GET /pins/1.json
  def show
    @pin = Pin.find(params[:id])
    @is_admin = current_user && current_user.id == @pin.user_id
    @related_paymentaccount = Paymentaccount.find_by_user_id(@pin.user_id)



    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pin }
    end
  end

  # GET /pins/new
  # GET /pins/new.json
  def new
    @pin = current_user.pins.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pin }
    end
  end

  # GET /pins/1/edit
  def edit
    @pin = current_user.pins.find(params[:id])
  end

  # POST /pins
  # POST /pins.json
  def create
    @pin = current_user.pins.new(params[:pin])

    respond_to do |format|
      if @pin.save
        format.html { redirect_to @pin, notice: 'Pin was successfully created.' }
        format.json { render json: @pin, status: :created, location: @pin }
      else
        format.html { render action: "new" }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pins/1
  # PUT /pins/1.json
  def update
    @pin = current_user.pins.find(params[:id])

    respond_to do |format|
      if @pin.update_attributes(params[:pin])
        format.html { redirect_to @pin, notice: 'Pin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pins/1
  # DELETE /pins/1.json
  def destroy
    @pin = current_user.pins.find(params[:id])
    @pin.destroy

    respond_to do |format|
      format.html { redirect_to pins_url }
      format.json { head :no_content }
    end
  end
  
  def pin_params
    params.require(:pin).permit(:event_name, :description, :image, :price)
  end

  # GET /farmers/oauth/1
  def oauth
    if !params[:code]
      return redirect_to('/')
    end

    redirect_uri = url_for(:controller => 'pins', :action => 'oauth', :pin_id => params[:pin_id], :host => request.host_with_port)
    @pin = Pin.find(params[:pin_id])
    begin
      @pin.request_wepay_access_token(params[:code], redirect_uri)
    rescue Exception => e
      error = e.message
    end

    if error
      redirect_to @pin, alert: error
    else
      redirect_to @pin, notice: 'We successfully connected you to WePay!'
    end
  end

  # GET /farmers/buy/1
  def buy
    redirect_uri = url_for(:controller => 'pins', :action => 'payment_success', :pin_id => params[:pin_id], :host => request.host_with_port)
    @pin = Pin.find(params[:pin_id])
    begin
      @checkout = @pin.create_checkout(redirect_uri)
    rescue Exception => e
      redirect_to @pin, alert: e.message
    end
  end

  # GET /farmers/payment_success/1
  def payment_success
    @pin = Pin.find(params[:pin_id])
    if !params[:checkout_id]
      return redirect_to @pin, alert: "Error - Checkout ID is expected"
    end
    if (params['error'] && params['error_description'])
      return redirect_to @pin, alert: "Error - #{params['error_description']}"
    end
    redirect_to @pin, notice: "Thanks for the payment! You should receive a confirmation email shortly."
  end
end
