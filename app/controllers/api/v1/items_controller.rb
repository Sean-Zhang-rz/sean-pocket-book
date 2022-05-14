class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.page(params[:page]).per(5)
    render json: {data: {
      items: items,
      page: params[:page],
      per_page: 5,
      count: Item.count
    }}
  end

  def create
    item = Item.new amount: 1
    if item.save
      render json: {data: item}
    else
      render json: {errors: item.errors}
    end
  end
end
