class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.where({created_at: params[:created_after]..params[:created_brefore]}).page(params[:page])
    render json: {data: {
      items: items,
      page: params[:page],
      per_page: 5,
      count: Item.count
    }}
  end

  def create
    item = Item.new amount: params[:amount]
    if item.save
      render json: {data: item}
    else
      render json: {errors: item.errors}
    end
  end
end
