class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.page params[:page]
    render json: {data: items}
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
