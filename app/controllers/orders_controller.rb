class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  

  # Transfer Funds to Seller/Put method
  def complete_purchase

    @order = Order.find(params[:id])

    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    token = params[:stripeToken]

    Stripe::Transfer.create(
      :amount => (@order.amount * 0.8572).floor,
      :currency => "usd",
      :destination => current_user.stripe_account,
      :description => "MY FRRIIIEENNDD",
      :source_transaction => @order.charge_id
    )
    redirect_to root_path
  end

  def cindarella
    @cid = params[:id]
    @kim = params[:home_number]
  end

  def sales
    @orders = Order.all.where(seller: current_user).order("created_at DESC")

  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    @profile = Profile.find(params[:profile_id])
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @profile = Profile.find(params[:profile_id])
    @seller = @profile.user

    @order.profile_id = @profile.id
    @order.buyer_id = current_user.id
    @order.seller_id = @seller.id

    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    token = params[:stripeToken]

    begin
      charge = Stripe::Charge.create(
        :amount => (@profile.price * 105).floor,
        :currency => "usd",
        :card => token,
        )
      flash[:notice] = "Thanks for ordering!"
    rescue Stripe::CardError => e
      flash[:danger] = e.message
    end

    @order.charge_id = charge.id
    @order.amount = charge.amount
    current_user.save

    respond_to do |format|
      if @order.save
        format.html { redirect_to root_path }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:address, :city, :state, :zipe_code)
    end
end
