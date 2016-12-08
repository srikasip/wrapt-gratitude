module Admin
  class TrainingSetsController < BaseController
    before_action :set_training_set, only: [:show, :edit, :update, :destroy]

    # GET /training_sets
    # GET /training_sets.json
    def index
      @training_sets = TrainingSet.order(:id).all
    end

    # GET /training_sets/1
    # GET /training_sets/1.json
    def show
      @gifts = Gift.all.page(params[:page]).per(50)
      @gift_question_impact_gift_ids = @training_set.gift_question_impacts.pluck "DISTINCT gift_id"
    end

    # GET /training_sets/new
    def new
      @training_set = TrainingSet.new
    end

    # GET /training_sets/1/edit
    def edit
    end

    # POST /training_sets
    # POST /training_sets.json
    def create
      @training_set = TrainingSet.new
      @training_set.assign_attributes training_set_params

      respond_to do |format|
        if @training_set.save
          format.html { redirect_to [:admin, @training_set], notice: 'Training set was successfully created.' }
          format.json { render :show, status: :created, location: @training_set }
        else
          format.html { render :new }
          format.json { render json: @training_set.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /training_sets/1
    # PATCH/PUT /training_sets/1.json
    def update
      respond_to do |format|
        if @training_set.update(training_set_params)
          format.html { redirect_to [:admin, @training_set], notice: 'Training set was successfully updated.' }
          format.json { render :show, status: :ok, location: @training_set }
        else
          format.html { render :edit }
          format.json { render json: @training_set.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /training_sets/1
    # DELETE /training_sets/1.json
    def destroy
      @training_set.destroy
      respond_to do |format|
        format.html { redirect_to admin_training_sets_url, notice: 'Training set was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_training_set
        @training_set = TrainingSet.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def training_set_params
        permitted_params = [:name]
        if @training_set.new_record? then permitted_params << :survey_id end
        params.require(:training_set).permit *permitted_params
      end
  end
end