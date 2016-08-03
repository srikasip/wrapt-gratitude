Rails.application.routes.draw do



  get 'home_pages/show'

  devise_for :users
  resources :product_categories
  resources :products
  resources :surveys do
    resources :questions, except: [:index], controller: 'survey_questions' do
      resources :options, except: [:index, :show], controller: 'survey_question_options'
    end
  end

  resources :training_sets do
    resources :product_questions, controller: 'training_set_product_questions', except: [:index, :show]
  end
  root to: 'home_pages#show' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
