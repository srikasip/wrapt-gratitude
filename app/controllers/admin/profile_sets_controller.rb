module Admin
  class ProfileSetsController < BaseController
    before_action :set_profile_set, only: [:show, :edit, :update, :destroy]

    def index
      @profile_sets = ProfileSet.all
    end

    def show
      @profile_set_survey_responses = @profile_set.survey_responses
    end

    def new
      @profile_set = ProfileSet.new
    end

    def edit
    end

    def create
      @profile_set = ProfileSet.new(profile_set_params)

      respond_to do |format|
        if @profile_set.save
          format.html { redirect_to @profile_set, notice: 'Training set was successfully created.' }
          format.json { render :show, status: :created, location: @profile_set }
        else
          format.html { render :new }
          format.json { render json: @profile_set.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @profile_set.update(profile_set_params)
          format.html { redirect_to @profile_set, notice: 'Training set was successfully updated.' }
          format.json { render :show, status: :ok, location: @profile_set }
        else
          format.html { render :edit }
          format.json { render json: @profile_set.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @profile_set.destroy
      respond_to do |format|
        format.html { redirect_to profile_sets_url, notice: 'Training set was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_profile_set
        @profile_set = ProfileSet.find(params[:id])
      end

      def profile_set_params
        params.require(:profile_set).permit :name, :survey_id
      end
  end
end