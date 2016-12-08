module Admin
  class SurveySectionOrderingsController < SortableListOrderingsController

    def sortables
      survey = Survey.find params[:survey_id]
      return survey.sections
    end

  end
end