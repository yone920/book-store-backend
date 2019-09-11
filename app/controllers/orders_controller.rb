class OrdersController < ApplicationController
    
    def index 
        orders = Order.all 
        render json: orders
    end

    def show 
        order_id = params[:id].to_i
        order = Order.find_by_id(order_id)
        render json: order
    end

    def create
        order = Order.create(order_params)
        render json: order
    end

    def neworder
        product_1 = Product.find(order_params[:product_id])
        quantity_1 = order_params[:quantity]


        order = Order.create(user_id: order_params[:user_id] )
        order_items = OrderItem.create(order_id: order.id, product_id: order_params[:product_id], quantity: order_params[:quantity], item_price: product_1.price_in_cents * quantity_1)
        user = User.find(order_params[:user_id])
        user.update(current_order: order.id )
        order_items = order.order_items



        total = 0
        total_quantity = 0
        order.order_items.each { |item| total += item.item_price }
        order.total_price = total

        order.order_items.each { |item| total_quantity += item.quantity }
        order.total_qty = total_quantity
        order.save




        render json: current_site_user, include: '**'
    end

    def shipping
        order = Order.find(params[:id].to_i)
        order.update(
            sh_rate: order_params[:sh_rate].to_i,     
        )

        ReportMailer.order_confirmation(current_site_user).deliver

        render json: current_site_user, include: '**'
    end

    def update
        order = Order.find(params[:id].to_i)
        order.update(
                sh_fname: order_params[:fname],
                sh_address: order_params[:address],
                sh_city: order_params[:city],
                sh_state: order_params[:state],
                sh_zip: order_params[:zip]
        )

        render json: current_site_user, include: '**'
    end

    private
    def order_params
        params.permit(:user_id, :product_id, :fname, :address, :city, :state, :zip, :order_id, :sh_rate, :quantity)
    end


end
