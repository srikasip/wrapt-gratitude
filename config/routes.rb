Rails.application.routes.draw do

  resources :vendors
  get 'home_pages/show'
  devise_for :users
  
  resources :product_categories
  resources :products
  resources :gifts do
    resources :products, only: [:index, :create, :destroy], controller: 'gift_products'
    resources :images, only: [:index, :create, :destroy], controller: 'gift_images' do
      member { post 'make_primary' }
    end
    resource :image_ordering, only: :create, controller: 'gift_image_orderings'
  end
  resources :surveys do
    resources :questions, except: :index, controller: 'survey_questions' do
      member do
        get :preview
      end
      resources :options, except: [:index], controller: 'survey_question_options' do
        resource :image, only: [:edit, :update, :destroy], controller: 'survey_question_option_images'
      end
      resource :option_ordering, only: :create, controller: 'survey_question_option_orderings'
    end
    resource :question_ordering, only: :create, controller: 'survey_question_orderings'
  end

  resources :training_sets do
    resources :gifts, only: :none do
      resources :questions, only: :index, controller: 'training_set_questions'
    end
    resources :gift_question_impacts, controller: 'gift_question_impacts', except: [:index, :show]
    resource :evaluation, only: :show, controller: 'training_set_evaluations' do
      resources :recommendations, only: :show, controller: 'evaluation_recommendations' do
        resources :gift_question_impacts, only: [:edit, :update], controller: 'recommendation_gift_question_impacts'
      end
    end
  end


  resources :profile_sets do
    resources :survey_responses, controller: 'profile_set_survey_responses', except: [:index, :show]
  end

  resource :private_access_session, only: [:new, :create, :destroy]

  root to: 'home_pages#show' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
