Rails.application.routes.draw do
  root to: 'home#show'

  if Rails.env.development?
    get 'terms-of-service', to: 'static_pages#terms_of_service', as: :terms_of_service
    get 'privacy-policy', to: 'static_pages#privacy_policy', as: :privacy_policy
  end

  get 'science-of-gifting', to: 'static_pages#science_of_gifting', as: :science_of_gifting

  resources :invitation_requests, only: :create

  ##########################
  # Survey responses
  # for MVP1A they can be accessed via notification link or logged in user
  ##########################
  concern :profile_builder do
    resources :profiles, only: [:new, :create] do
      resources :surveys, only: :show, controller: 'survey_responses' do
        resources :questions, only: [:show, :update], controller: 'survey_question_responses'
        resource :completion, only: [:show, :create], controller: 'survey_response_completions'
      end
    end
  end

  concerns :profile_builder
  resources :invitations, only: :show, concerns: :profile_builder

  resources :profiles, only: :none do
    resources :gift_recommendations, only: :index
    resources :gift_selections, only: [:create, :destroy]
    resources :giftee_invitations, only: [:new, :create]
    resources :gift_likes, only: [:create, :destroy]
    resources :gift_dislikes, only: [:create, :destroy]
    resources :recipient_gift_likes, only: [:create, :destroy]
    resources :recipient_gift_dislikes, only: [:create, :destroy]
    resources :recipient_gift_selections, only: [:create, :destroy]
    resources :recipient_originated_referrals, only: [:new, :create]
  end

  resources :profile_recipient_reviews, only: :show
  resources :funds, only: :index

  # removed pt story #149729697
  # resources :mvp1b_user_surveys, only: [:show, :new, :create]

  get 'testing/survey_complete', to: 'survey_response_completions#show'
  get 'testing/gift_recommendations', to: 'gift_recommendations#index'


  #####################################################

  ##################################
  # User Authentication
  ##################################
  resource :user_session, only: [:new, :create, :destroy]
  resources :password_reset_requests, only: [:new, :create]
  resources :password_resets, only: [:show, :update]

  ###################################
  # My Account Area
  ###################################
  resource :my_account, only: [:show, :edit, :update]

  ###################################
  ### Checkout and shopping cart
  ###################################
  namespace :ecommerce do
    resources :line_items

    VALID_STEPS = ['gift-wrap', 'shipping', 'payment', 'review', 'finalize']
    VALID_STEPS.each do |step|
      action = step.tr('-', '_')
      get "checkout/#{step}" => "checkout#show_#{action}"
      put "checkout/#{step}" => "checkout#save_#{action}"
    end

    resources :vendor_confirmations, only: [:show, :update] do
      collection do
        get :error
        get :thanks
      end
    end
  end

  ###################################
  ### Admin
  ###################################
  namespace :admin do
    root to: 'home#show', as: 'root' # admin home

    resources :users, except: :show do
      member do
        post :resend_invitation
      end
      collection do
        get :pending_invites
      end
    end
    resources :user_imports, only: [:new, :create]
    resources :invitation_requests, only: [:index, :update, :destroy]

    resources :public_survey_exports, only: [:create]
    resources :gift_tag_exports, only: [:create]
    resources :gift_tag_imports, only: [:new, :create]

    resources :vendors
    resources :survey_responses, only: [:show]

    resources :product_categories, except: :show do
      resource :subcategories, controller: 'product_subcategories', only: :show
    end
    resources :products do
      resources :images, only: [:index, :new, :create, :destroy], controller: 'product_images' do
        member { post 'make_primary' }
      end
      resource :image_ordering, only: :create, controller: 'product_image_orderings'
      resource :single_product_gift, only: [:new, :create]
    end
    resources :gifts do
      resources :products, only: [:index, :create, :destroy], controller: 'gift_products'
      resources :images, only: [:index, :new, :create, :destroy], controller: 'gift_images' do
        member { post 'make_primary' }
      end
      resource :image_ordering, only: :create, controller: 'gift_image_orderings'
      resources :images_from_products, only: :create, controller: 'gift_images_from_products'
      resource :preview, only: :show, controller: 'gift_previews'
      resource :preview_modal, only: :show, controller: 'gift_preview_modals'
    end
    resources :faux_single_product_gifts, only: [:index, :update]
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
      resource :sectioned_question_ordering, only: :create, controller: 'survey_sectioned_question_orderings'
      resource :copying, only: :create, controller: 'survey_copyings'
      resources :sections, except: :show, controller: 'survey_sections'
      resource :section_ordering, only: :create, controller: 'survey_section_orderings'
      resource :publishing, only: [:create], controller: 'survey_publishings'
    end

    resources :reports, only: :index
    resources :mvp1b_user_surveys, only: :index
    resources :top_gifts_reports, only: :index
    resources :survey_response_reports, only: :index

    namespace :ecommerce do
      get '/' => 'dashboard#index'
      resources :inventory_items, only: [:index] do
        collection do
          get :upload, action: 'upload_form'
          put :upload
          get :download
        end
      end
      resources :billings, only: [:index]
      resources :customer_orders, only: [:index, :show, :destroy, :create]
      resources :purchase_orders, only: [:index, :show] do
        member do
          put :resend_notification
        end
      end
      post 'webhooks/tracking' => 'webhooks#tracking'
    end

  end

  ####################
  ## Misc
  ####################
  unless Rails.env.production?
    resource :style_guide, only: :none do
      member do
        # Add style guide routes here and to app/controllers/style_guides_controller.rb
        get 'main'
      end
    end
  end

  require 'sidekiq/web'
  constraints lambda {|request| SidekiqDashboardAuthentication.authenticated? request} do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount LetsencryptPlugin::Engine, at: '/'  # It must be at root level

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

end
