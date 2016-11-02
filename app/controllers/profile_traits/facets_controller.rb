class ProfileTraits::FacetsController < ApplicationController
  before_action :set_topic
  before_action :set_profile_traits_facet, only: [:edit, :update, :destroy]
  helper ProfileTraitsHelper

  def index
    @profile_traits_facets = @topic.facets.all
  end

  def new
    @profile_traits_facet = @topic.facets.new
  end

  def edit
  end

  def create
    @profile_traits_facet = @topic.facets.new(profile_traits_facet_params)

    if @profile_traits_facet.save
      redirect_to profile_traits_topic_facets_path(@topic), notice: 'Facet was successfully created.'
    else
      render :new
    end
  end

  def update
    if @profile_traits_facet.update(profile_traits_facet_params)
      redirect_to profile_traits_topic_facets_path(@topic), notice: 'Facet was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @profile_traits_facet.destroy
    redirect_to profile_traits_topic_facets_path(@topic), notice: 'Facet was successfully destroyed.'
  end

  private
    def set_topic
      @topic = ProfileTraits::Topic.find params[:topic_id]
    end

    def set_profile_traits_facet
      @profile_traits_facet = @topic.facets.find(params[:id])
    end

    def profile_traits_facet_params
      params.require(:profile_traits_facet).permit(:topic_id, :name)
    end
end