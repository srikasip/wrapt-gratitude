class ProfileTraits::TagsController < ApplicationController
  before_action :set_topic
  before_action :set_facet
  before_action :set_tag, only: [:edit, :update, :destroy]
  helper ProfileTraitsHelper

  def index
    @tags = @facet.tags.all
  end

  def new
    @tag = @facet.tags.new
  end

  def edit
  end

  def create
    @tag = @facet.tags.new(tag_params)

    if @tag.save
      redirect_to profile_traits_topic_facet_tags_path(@topic, @facet), notice: 'Facet was successfully created.'
    else
      render :new
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to profile_traits_topic_facet_tags_path(@topic, @facet), notice: 'Facet was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to profile_traits_topic_facet_tags_path(@topic, @facet), notice: 'Facet was successfully destroyed.'
  end

  private
    def set_topic
      @topic = ProfileTraits::Topic.find params[:topic_id]
    end

    def set_facet
      @facet = @topic.facets.find params[:facet_id]
    end

    def set_tag
      @tag = @facet.tags.find(params[:id])
    end

    def tag_params
      params.require(:profile_traits_tag).permit(:name, :position)
    end
end
