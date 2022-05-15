class HomeController < ApplicationController
  def index
    render json: {
      message: "hello Rails"
    }
  end
end
