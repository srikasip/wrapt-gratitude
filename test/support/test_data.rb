class TestData
  
  attr_reader :incense_product,
    :tipi_product,
    :survey,
    :training_set,
    :rafe_response,
    :ely_response

  def load_data!
    @incense_product = Product.create! title: "Juniper Ridge Campfire Incese", description: "", price: "5.99"
    @tipi_product = Product.create! title: "Tipi", description: "A \"guest bedroom\" for The Big Kid by Nomadic Tipi Makers", price: "1199.99"

    @survey = Survey.create! title: "Test Survey"

    @multiple_choice_question = SurveyQuestions::MultipleChoice.create!(
      survey: @survey,
      prompt: "What's her favorite color?"
    )

    @red_option = SurveyQuestionOption.create!(
      question: @multiple_choice_question,
      text: 'Red'
    )

    @blue_option = SurveyQuestionOption.create!(
      question: @multiple_choice_question,
      text: 'Blue'
    )

    @green_option = SurveyQuestionOption.create!(
      question: @multiple_choice_question,
      text: 'Green'
    )

    @range_question = SurveyQuestions::Range.create!(
      survey: @survey,
      prompt: 'How likely is this person to go barefoot?',
      min_label: 'Never',
      max_label: 'Always'
    )

    @profile_set = ProfileSet.create! name: "Test Profile Set", survey: @survey

    @ely_response = ProfileSetSurveyResponse.create! name: 'Ely', profile_set: @profile_set
    @rafe_response = ProfileSetSurveyResponse.create! name: 'Rafe', profile_set: @profile_set

    SurveyQuestionResponse.create!(
      survey_response: @ely_response,
      survey_question: @multiple_choice_question,
      survey_question_option: @red_option
    )
    
    SurveyQuestionResponse.create!(
      survey_response: @ely_response,
      survey_question: @range_question,
      range_response: -0.66
    )

    SurveyQuestionResponse.create!(
      survey_response: @rafe_response,
      survey_question: @multiple_choice_question,
      survey_question_option: @green_option
    )

    SurveyQuestionResponse.create!(
      survey_response: @rafe_response,
      survey_question: @range_question,
      range_response: 0.5
    )

    @training_set = TrainingSet.create! name: "Test Training Set", survey: @survey
    @training_set.create_evaluation!


    @tipi_multiple_choice = TrainingSetProductQuestion.create! training_set: @training_set, product: @tipi_product, survey_question: @multiple_choice_question, question_impact: 0.79
    @tipi_range = TrainingSetProductQuestion.create! training_set: @training_set, product: @tipi_product, survey_question: @range_question, question_impact: -0.34

    @incense_multiple_choice = TrainingSetProductQuestion.create! training_set: @training_set, product: @incense_product, survey_question: @multiple_choice_question, question_impact: -0.5
    @incense_range = TrainingSetProductQuestion.create! training_set: @training_set, product: @incense_product, survey_question: @range_question, question_impact: 0.55, range_impact_direct_correlation: false

    TrainingSetResponseImpact.create! training_set_product_question: @tipi_multiple_choice, survey_question_option: @red_option, impact: -0.6
    TrainingSetResponseImpact.create! training_set_product_question: @tipi_multiple_choice, survey_question_option: @green_option, impact: 0.73
    TrainingSetResponseImpact.create! training_set_product_question: @tipi_multiple_choice, survey_question_option: @blue_option, impact: 0

    TrainingSetResponseImpact.create! training_set_product_question: @incense_multiple_choice, survey_question_option: @red_option, impact: 0.4
    TrainingSetResponseImpact.create! training_set_product_question: @incense_multiple_choice, survey_question_option: @green_option, impact: -0.8
    TrainingSetResponseImpact.create! training_set_product_question: @incense_multiple_choice, survey_question_option: @blue_option, impact: 0.2

  end

  def cleanup!
    # this should clean everything up via dependent: destroy
    incense_product.destroy!
    tipi_product.destroy!
    survey.destroy!
  end

end