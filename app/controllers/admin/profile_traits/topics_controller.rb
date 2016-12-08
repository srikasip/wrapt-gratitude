module Admin
  class ProfileTraits::TopicsController < BaseController
    before_action :set_profile_traits_topic, only: [:edit, :update, :destroy]
    helper ProfileTraitsHelper


    def index
      @profile_traits_topics = ProfileTraits::Topic.all
    end

    def new
      @profile_traits_topic = ProfileTraits::Topic.new
    end

    def edit
    end

    def create
      @profile_traits_topic = ProfileTraits::Topic.new(profile_traits_topic_params)

      if @profile_traits_topic.save
        redirect_to admin_profile_traits_topics_path, notice: 'Topic was successfully created.'
      else
        render :new
      end
    end

    def update
      if @profile_traits_topic.update(profile_traits_topic_params)
        redirect_to admin_profile_traits_topics_path, notice: 'Topic was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @profile_traits_topic.destroy
      redirect_to admin_profile_traits_topics_url, notice: 'Topic was successfully destroyed.'
    end

    private
      def set_profile_traits_topic
        @profile_traits_topic = ProfileTraits::Topic.find(params[:id])
      end

      def profile_traits_topic_params
        params.require(:profile_traits_topic).permit(:name)
      end
  end
end