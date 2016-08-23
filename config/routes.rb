Rails.application.routes.draw do



  get 'home_pages/show'

  devise_for :users
  resources :product_categories
  resources :products
  resources :surveys do
    resources :multiple_choice_questions, except: [:index], controller: 'survey_questions/multiple_choices' do
      resources :options, except: [:index, :show], controller: 'survey_question_options'
    end
    resources :text_questions, except: [:index, :show], controller: 'survey_questions/texts'
    resources :range_questions, except: [:index, :show], controller: 'survey_questions/ranges'
  end

  resources :training_sets do
    resources :product_questions, controller: 'training_set_product_questions', except: [:index, :show] do
      resources :range_impact_correlation_switchings, only: :create
    end
    resource :evaluate, only: :show, controller: 'training_set_evaluations'
  end


  resources :profile_sets do
    resources :survey_responses, controller: 'profile_set_survey_responses', except: [:index, :show]
  end

  root to: 'home_pages#show' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
