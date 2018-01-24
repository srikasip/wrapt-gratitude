class GifteeSurveyResponsesController < ApplicationController

  before_action :set_profile

  helper SurveyQuestionResponsesHelper
  include PjaxModalController
  
  def index
    # the route to this is gone
    # nice to have around for debugging
  end

  def new
    # ask if they want to shop for profile they already have
    @disable_close = true
    @relationship_profiles = current_user.owned_profiles.
      unarchived.active.
      where(relationship: @profile.relationship).
      where.not(first_name: 'Unknown')
  end

  def create
    # new profile gets deleted in update action
    @profile_to_be_removed = @profile
    # copy last survey response for old profile
    @profile = Profile.find(params[:shopping_trip][:profile_id])
    @disable_close = true
    make_a_copy!(@profile)
  end

  def edit
    load_last_survey_response(@profile)
  end

  def update
    @survey_response = SurveyResponse.find(params[:id])
    if @survey_response.update_attributes(survey_response_params)
      @profile.has_viewed_initial_recommendations = true
      @profile.save
      job = GenerateRecommendationsJob.new
      job.perform(@profile, survey_response_id: @survey_response.id, append: true)
      if params[:profile_to_be_removed].present?
        @profile_to_be_removed = current_user.owned_profiles.where(id: params[:profile_to_be_removed]).first
        @profile_to_be_removed.destroy if @profile_to_be_removed.present?
      end
      redirect_to giftee_gift_recommendations_path(@profile)
    else
      flash[:alert] = "Sorry, sometheing went wrong! Please try again!"
      render :edit
    end
  end

  def copy
    make_a_copy!(@profile)
  end

  private

  def make_a_copy!(profile_to_copy)
    load_last_survey_response(profile_to_copy)
    begin
      SurveyResponse.transaction do
        @copy = profile_to_copy.copy_last_survey_response!
        @copy.question_responses.each do |question_response|
          to_be_copied = (@last_survey_question_responses[question_response.survey_question] || []).first
          if to_be_copied.present?
            question_response.update_attributes!(to_be_copied.copy_attributes) 
            to_be_copied.survey_question_response_options.each do |option|
              question_response.copy_option!(option)
            end
          end
        end
      end
    rescue => e
      flash[:alert] = "Sorry, sometheing went wrong! Please try again!"
      redirect_to my_account_giftees_path
    end
    render :edit
  end

  def survey_response_params
    params.require(:survey_response).permit(
      question_responses_attributes: [
        :survey_question_option_ids,
        :id,
        :range_response,
        :text_response,
        :other_option_text,
        survey_question_option_ids: []
      ]
    )
  end

  def login_required?
    true
  end

  def set_profile
    @profile = current_user.owned_profiles.find params[:giftee_id]
  end

  def load_last_survey_response(profile)
    @last_survey_response = profile.last_survey
    @last_survey_question_responses = @last_survey_response.question_responses.group_by(&:survey_question)
  end

end