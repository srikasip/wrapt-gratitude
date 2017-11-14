Rails.application.routes.draw do
  root to: 'home#show'

  
  get 'terms-of-service', to: 'static_pages#terms_of_service', as: :terms_of_service
  get 'privacy-policy', to: 'static_pages#privacy_policy', as: :privacy_policy
  get 'returns-policy', to: 'static_pages#returns_policy', as: :returns_policy
  

  get 'science-of-gifting', to: 'static_pages#science_of_gifting', as: :science_of_gifting
  get 'rewrapt', to: 'static_pages#rewrapt', as: :rewrapt
  get 'about', to: 'static_pages#about', as: :about

  resources :invitation_requests, only: :create

  ##########################
  # Survey responses
  # for MVP1A they can be accessed via notification link or logged in user
  ##########################
  concern :profile_builder do
    resources :giftees, only: [:index, :new, :create] do
      resources :surveys, only: :show, controller: 'survey_responses' do
        resources :questions, only: [:show, :update], controller: 'survey_question_responses'
        resource :completion, only: [:show, :create], controller: 'survey_response_completions' do
          collection do
            get :create_via_redirect
          end
        end
      end
    end
  end

  concerns :profile_builder
  resources :invitations, only: :show, concerns: :profile_builder

  resources :giftees, only: [:new, :create] do
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
  #namespace :my_account, path: 'my-account' do
  resource :my_account, path: 'my-account', module: 'my_account' do
    resources :giftees, only: [ :new, :index, :edit, :update ]
    resource :profile, only: [ :show, :edit, :update ]
    resources :orders, only: [ :index, :show ]
    resources :billing, only: [:index] do
      resources :addresses
    end
    resources :preferences, only: [ :index ]
  end

  ###################################
  ### Checkout and shopping cart
  ###################################
  namespace :ecommerce do
    patch "checkout/start/:giftee_id" => "checkout#start", as: 'checkout_start'
    VALID_STEPS = ['gift-wrapt', 'giftee-name', 'address', 'shipping', 'payment', 'review']
    VALID_STEPS.each do |step|
      action = step.tr('-', '_')
      get "checkout/#{step}" => "checkout#edit_#{action}"
      patch "checkout/#{step}" => "checkout#save_#{action}"
    end
    get "checkout/finalize" => "checkout#finalize"

    resources :vendor_confirmations, only: [:show, :update] do
      member do
        get :details
        patch :change_shipping
      end
      collection do
        get :error
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
        get :export
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
      collection do
        resources :exports, only: [:create], as: 'products_exports', controller: 'products_exports'
      end
    end
    resources :gifts do
      member do
        post :add_to_recommendations
      end
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
      get '/stats' => 'dashboard#stats'
      resources :inventory_items, only: [:index] do
        collection do
          get :upload, action: 'upload_form'
          put :upload
          get :download
        end
      end
      resources :billings, only: [:index]
      resources :customer_orders, only: [:index, :show, :destroy, :create] do
        member do
          post :send_customer_notification
        end
      end
      resources :purchase_orders, only: [:index, :show] do
        member do
          post :send_vendor_notification
          delete :cancel_order
          post :send_order_shipped_notification
        end
      end
      post 'webhooks/tracking' => 'webhooks#tracking'
    end

    resources :comments, only: [:create]
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

  get 'health-check' => 'health_check#index'
  get 'exception-check' => 'health_check#exception'

  get '*args' => 'static_pages#page_404'
end
