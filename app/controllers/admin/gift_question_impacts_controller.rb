module Admin
  class GiftQuestionImpactsController < BaseController
    before_action :set_training_set
    before_action :set_gift_question_impact, only: [:show, :edit, :update, :destroy]

    def new
      @gift_question_impact = @training_set.gift_question_impacts.new
      @gift_question_impact.gift_id = params[:gift_id]
    end

    def edit
    end

    def create
      @gift_question_impact = @training_set.gift_question_impacts.new(gift_question_impact_params)

      if @gift_question_impact.save
        @gift_question_impact.create_response_impacts
        redirect_to edit_admin_training_set_gift_question_impact_path(@training_set, @gift_question_impact), notice: 'Gift-Question was successfully created.'
      else
        render :new
      end
    end

    def update
      if @gift_question_impact.update(gift_question_impact_params)
        redirect_to [:admin, @training_set], notice: 'Gift-Question was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @gift_question_impact.destroy
      redirect_to [:admin, @training_set], notice: 'Gift-Question was successfully destroyed.'
    end

    private
      def set_training_set
        @training_set = TrainingSet.find params[:training_set_id]
      end

      def set_gift_question_impact
        @gift_question_impact = @training_set.gift_question_impacts.find(params[:id])
      end

      def gift_question_impact_params
        params.require(:gift_question_impact).permit(
          :gift_id,
          :survey_question_id,
          :question_impact,
          :range_impact_direct_correlation,
          response_impacts_attributes: [:id, :impact]
        )
      end
  end
end