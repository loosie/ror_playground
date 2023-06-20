module CurrentCart
  private

  def set_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    # If the cart is not found, create a new one
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end
end