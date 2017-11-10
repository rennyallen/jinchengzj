class ResourcesController < ApplicationController
  before_action :find_resource, only: [:show, :edit, :update]

  def index
    @resources = Resource.order('created_at desc')
  end

  def create
    create_corresponding_topic
    create_resource
    redirect_to resources_path
  end

  def show
    @replies = Reply.where(resource_id: @resource.id)
  end

  def new
    @resource = Resource.new
    render params[:type] == 'lost' ? 'new_lost' : 'new_found'
  end

  def edit
    render 'edit_lost'
  end

  def update
    @resource.update(resource_params)
    @resource.topic.update(title: resource_params[:title])
  end

  def found
    @resources = Resource.found
    render 'index'
  end

  def create_resource
    @resource = Resource.new(resource_params)
    @resource.user_id = current_user.id
    @resource.topic_id = @topic.id
    @resource.save
  end

  def create_corresponding_topic
    @topic = Topic.create(
      user_id: current_user.id,
      title: resource_params[:title],
      node_id: 7,      # 这是“失物招领”的node_id
      body: "")   # the body is useless for resources
  end

  private 

  def find_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.require(:resource).permit(:lost_or_found, :res_type, :date, :title, :description)
  end
end