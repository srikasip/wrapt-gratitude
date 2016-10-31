Rails.application.routes.draw do

  resources :trait_training_sets, except: :show do
    resources :questions, except: :show, controller: 'trait_training_set_questions' do
      resources :response_impacts, only: :index, controller: 'trait_training_set_response_impacts'
    end
  end
  namespace :profile_traits, except: :show do
    resources :topics do
      resources :facets, except: :show do
        resources :tags, except: :show
      end
    end
  end

  resources :vendors
  get 'home_pages/show'
  devise_for :users
  
  resources :product_categories, except: :show do
    resource :subcategories, controller: 'product_subcategories', only: :show
  end
  resources :products do
    resources :images, only: [:index, :new, :create, :destroy], controller: 'product_images' do
      member { post 'make_primary' }
    end
    resource :image_ordering, only: :create, controller: 'product_image_orderings'
    resource :single_product_gift, only: :create
  end
  resources :gifts do
    resources :products, only: [:index, :create, :destroy], controller: 'gift_products'
    resources :images, only: [:index, :new, :create, :destroy], controller: 'gift_images' do
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

      # note: index route only exists for dynamic url generation
      resources :conditional_question_options, only: [:index, :show]
    end
    resource :question_ordering, only: :create, controller: 'survey_question_orderings'
    resource :copying, only: :create, controller: 'survey_copyings'
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
    resources :imports, controller: 'training_sets/imports', only: [:new, :create]
  end


  resources :profile_sets do
    resources :survey_responses, controller: 'profile_set_survey_responses', except: [:index, :show]
    resources :imports, controller: 'profile_sets/imports', only: [:new, :create]
  end

  resource :private_access_session, only: [:new, :create, :destroy]

  require 'sidekiq/web'
  constraints lambda {|request| SidekiqDashboardAuthentication.authenticated? request} do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'home_pages#show' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
