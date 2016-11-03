class TraitTrainingSetsController < ApplicationController
  before_action :set_trait_training_set, only: [:show, :edit, :update, :destroy]
  helper TraitTrainingSetsSectionHelper

  def index
    @trait_training_sets = TraitTrainingSet.all
  end

  def new
    @trait_training_set = TraitTrainingSet.new
  end

  def edit
  end

  def create
    @trait_training_set = TraitTrainingSet.new(trait_training_set_params)

    if @trait_training_set.save
      redirect_to trait_training_set_questions_path(@trait_training_set), notice: 'Profile Trait Training Set was successfully created.'
    else
      render :new
    end
  end

  def update
    if @trait_training_set.update(trait_training_set_params)
      redirect_to @trait_training_set, notice: 'Profile Trait Training Set was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @trait_training_set.destroy
    redirect_to trait_training_sets_url, notice: 'Profile Trait Training Set was successfully deleted.'
  end

  private
    def set_trait_training_set
      @trait_training_set = TraitTrainingSet.find(params[:id])
    end

    def trait_training_set_params
      params.require(:trait_training_set).permit(:name, :survey_id)
    end
end
