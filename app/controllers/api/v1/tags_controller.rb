class Api::V1::TagsController < ApplicationController
  def index
    current_user = User.find request.env['current_user_id']
    return render status: 401 if current_user.nil?
    tags = Tag.where(kind: params[:kind]).where(user_id: current_user.id).page(params[:page])
    render json: {data: {
      tagList: tags, 
      pager: {
      page: params[:page] || 1,
      per_page: Tag.default_per_page,
      count: Tag.count
    }
    }}
  end

  def show
    tag = Tag.find params[:id]
    if not tag.user_id === request.env['current_user_id']
      return render json: { msg: '未找到对应标签' }, status: :forbidden
    end
    render json: { data: tag }
  end

  def create
    current_user = User.find request.env['current_user_id']
    return render status: 401 if current_user.nil?

    tag = Tag.new name: params[:name], sign: params[:sign], user_id: current_user.id
    if tag.save
      render json: {data: tag}, status: 200
    else
      error1 = tag.errors.messages[:name][0]
      error2 = tag.errors.messages[:sign][0]
      render json: {msg: error1 || error2}, status: 422
    end
  end

  def update
    tag = Tag.find params[:id]
    tag.update params.permit(:name, :sign)
    if tag.errors.empty?
      render json: {data: tag}, status: 200
    else
      error1 = tag.errors.messages[:id][0]
      render json: {msg: error1}, status: :unprocessable_entity
    end
  end

  def destroy
    tag = Tag.find params[:id]
    if not tag.user_id === request.env['current_user_id']
      return render status: :forbidden
    end
    tag.deleted_at = Time.now
    if tag.save
      head 200
    else
      error1 = tag.errors.messages[:id][0]
      render json: {msg: error1}, status: :unprocessable_entity
    end
  end
end
