RapidFTR::Application.routes.draw do

  match '/' => 'home#index', :as => :root, :via => :get

  #######################
  # USER URLS
  #######################

  resources :users do
    collection do
      get :change_password
      get :unverified
      post :update_password
      post :register_unverified
      get :contact
    end
  end

  resources :sessions, :except => :index
  match 'login' => 'sessions#new', :as => :login, :via => [:post, :get, :put, :delete]
  match 'logout' => 'sessions#destroy', :as => :logout, :via => [:post, :get, :put, :delete]
  match '/active' => 'sessions#active', :as => :session_active, :via => [:post, :get, :put, :delete]

  resources :user_preferences
  resources :password_recovery_requests, :only => [:new, :create]
  match 'password_recovery_request/:password_recovery_request_id/hide' => 'password_recovery_requests#hide', :as => :hide_password_recovery_request, :via => :delete

  resources :devices
  match 'devices/update_blacklist' => 'devices#update_blacklist', :via => :post

  resources :roles
  match 'admin' => 'admin#index', :as => :admin, :via => [:post, :get, :put, :delete]
  match 'admin/update' => 'admin#update', :as => :admin_update, :via => [:post, :get, :put, :delete]

  #######################
  # CHILD URLS
  #######################

  resources :children do
    collection do
      post :sync_unverified
      post :reindex
      get :advanced_search
    end

    resources :attachments, :only => :show
    resource :duplicate, :only => [:new, :create]
  end

  get '/search', :to => 'search#search', :as => 'search'

  match '/children-ids' => 'child_ids#all', :as => :child_ids, :via => [:post, :get, :put, :delete]
  match '/children/:id/photo/edit' => 'children#edit_photo', :as => :edit_photo, :via => :get
  match '/children/:id/photo' => 'children#update_photo', :as => :update_photo, :via => :put
  match '/children/:child_id/photos_index' => 'media#index', :as => :photos_index, :via => [:post, :get, :put, :delete]
  match '/children/:child_id/photos' => 'media#manage_photos', :as => :manage_photos, :via => [:post, :get, :put, :delete]
  match '/children/:child_id/audio(/:id)' => 'media#download_audio', :as => :child_audio, :via => [:post, :get, :put, :delete]
  match '/children/:child_id/photo/:photo_id' => 'media#show_photo', :as => :child_photo, :via => [:post, :get, :put, :delete]
  match '/children/:child_id/photo' => 'media#show_photo', :as => :child_legacy_photo, :via => [:post, :get, :put, :delete]
  match 'children/:child_id/select_primary_photo/:photo_id' => 'children#select_primary_photo', :as => :child_select_primary_photo, :via => :put
  match '/children/:child_id/resized_photo/:size' => 'media#show_resized_photo', :as => :child_legacy_resized_photo, :via => [:post, :get, :put, :delete]
  match '/children/:child_id/photo/:photo_id/resized/:size' => 'media#show_resized_photo', :as => :child_resized_photo, :via => [:post, :get, :put, :delete]
  match '/children/:child_id/thumbnail(/:photo_id)' => 'media#show_thumbnail', :as => :child_thumbnail, :via => [:post, :get, :put, :delete]
  match '/children' => 'children#index', :as => :child_filter, :via => [:post, :get, :put, :delete]

  #######################
  # ENQUIRY URLS
  #######################
  resources :enquiries do
    get 'matches', :on => :collection
    resources :potential_matches, :only => [:destroy]
  end

  match '/enquiries/:enquiry_id/photo/:photo_id' => 'media#show_photo', :as => :enquiry_photo, :via => [:get]
  match '/enquiries/:enquiry_id/photo' => 'media#show_photo', :as => :enquiry_legacy_photo, :via => [:post, :get, :put, :delete]
  match '/enquiries/:enquiry_id/audio(/:id)' => 'media#download_audio', :as => :enquiry_audio, :via => [:get]
  match '/enquiries/:enquiry_id/resized_photo/:size' => 'media#show_resized_photo', :as => :enquiry_legacy_resized_photo, :via => [:get]
  match '/enquiries/:enquiry_id/thumbnail(/:photo_id)' => 'media#show_thumbnail', :as => :enquiry_thumbnail, :via => [:get]
  #######################
  # API URLS
  #######################

  namespace :api do
    controller :form_sections, :defaults => {:format => :json} do
      get 'form_sections', :action => :index
    end

    controller :device, :defaults => {:format => :json} do
      get 'is_blacklisted', :action => 'blacklisted'
      get 'is_blacklisted/:imei', :action => 'blacklisted'
    end

    controller :sessions, :defaults => {:format => :json} do
      post :login
      post :register
      post :logout
    end

    # CHILDREN

    resources :children do
      collection do
        get :ids, :defaults => {:format => :json}
        post :unverified, :defaults => {:format => :json}
      end

      member do
        controller :child_media do
          get 'photo(/:photo_id)', :action => 'show_photo'
          get 'audio(/:audio_id)', :action => 'download_audio'
        end
      end
    end

    # ENQUIRIES

    resources :enquiries, :defaults => {:format => :json}

    # POTENTIAL MATCH

    resources :potential_matches, :only => [:index, :show]

  end

  # Backwards compatibility with 1.2
  match '/published_form_sections', :to => 'api/form_sections#children', :via => [:post, :get, :put, :delete]

  #######################
  # FORM SECTION URLS
  #######################

  resources :standard_forms, :only => :index
  match '/standard_forms', :to => 'forms#bulk_update', :via => [:put, :post]
  resources :forms do
    resources :form_sections, :path => 'form_section', :controller => 'form_section', :only => [:index, :new, :create]
  end

  resources :form_sections, :path => 'form_section', :controller => 'form_section', :except => [:index, :new, :create] do

    collection do
      match 'save_order', :via => [:post, :get, :put, :delete]
      match 'toggle', :via => [:post, :get, :put, :delete]
    end

    resources :fields, :controller => 'fields' do
      collection do
        post 'save_order'
        post 'delete'
        post 'toggle_fields'
        post 'change_form'
      end
    end
  end

  resources :highlight_fields do
    collection do
      post :remove
    end
  end

  #######################
  # ADVANCED SEARCH URLS
  #######################

  match 'advanced_search/index', :to => 'advanced_search#index', :via => [:post, :get, :put, :delete]
  match 'advanced_search/export_data' => 'advanced_search#export_data', :as => :export_data_children, :via => :post

  #######################
  # LOGGING URLS
  #######################

  resources :system_logs, :only => :index
  match '/children/:id/history' => 'child_histories#index', :as => :child_history, :via => :get
  match '/enquiries/:id/history' => 'enquiry_histories#index', :as => :enquiry_history, :via => :get
  match '/users/:id/history' => 'user_histories#index', :as => :user_history, :via => :get

  #######################
  # REPLICATION URLS
  #######################

  resources :replications, :path => '/devices/replications' do
    collection do
      post :configuration
    end

    member do
      post :start
      post :stop
    end
  end

  resources :system_users, :path => '/admin/system_users'

  #######################
  # REPORTING URLS
  #######################
  resources :reports, :only => [:index, :show]

  #######################
  # TESTING URLS
  #######################
  if Rails.env.android? || Rails.env.test? || Rails.env.development? || Rails.env.cucumber?
    match 'database/delete_data/:data_type' => 'database#delete_data', :as => :reset_data, :via => :delete
    match 'database/reset_fieldworker' => 'database#reset_fieldworker', :as => :reset_fieldworker, :via => :delete
  end

end
