module Admin
  class SurveySectionsController < BaseController
    before_action :set_survey
    before_action :set_survey_section, only: [:edit, :update, :destroy]

    helper SurveyAdminSectionHelper

    def index
      @survey_sections = @survey.sections.all
    end

    def new
      @survey_section = @survey.sections.new
    end

    def edit
    end

    def create
      @survey_section = @survey.sections.new(survey_section_params)

      if @survey_section.save
        redirect_to survey_sections_path(@survey), notice: 'New Survey Section created.'
      else
        render :new
      end
    end

    def update
      if @survey_section.update(survey_section_params)
        redirect_to survey_sections_path(@survey), notice: 'Survey Section updated.'
      else
        render :edit
      end
    end

    def destroy
      @survey_section.destroy
      redirect_to survey_sections_url, notice: 'Survey Section deleted.'
    end

    private
      def set_survey
        @survey = Survey.find params[:survey_id]
      end

      def set_survey_section
        @survey_section = @survey.sections.find(params[:id])
      end

      def survey_section_params
        params.require(:survey_section).permit(:name, :sort_order)
      end
  end
end