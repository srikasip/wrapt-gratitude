Rails.application.routes.draw do
  resources :product_categories
  resources :products
  resources :surveys do
    resources :questions, except: [:index, :show], controller: 'survey_questions' do
      resources :options, except: [:index, :show], controller: 'survey_question_options'
    end
  end
  root to: 'products#index' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
