RapidFTR::Application.routes.draw do

match '/' => 'home#index', :as => :root

#######################
# USER URLS
#######################

  resources :users do
    collection do
      get :change_password
      get :unverified
      post :update_password
    end
  end
  match '/users/register_unverified' => 'users#register_unverified', :as => :register_unverified_user, :via => :post

  resources :sessions, :except => :index
  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match '/active' => 'sessions#active', :as => :session_active

  resources :user_preferences
  resources :password_recovery_requests, :only => [:new, :create]
  match 'password_recovery_request/:password_recovery_request_id/hide' => 'password_recovery_requests#hide', :as => :hide_password_recovery_request, :via => :delete

  resources :contact_information

  resources :devices
  match 'devices/update_blacklist' => 'devices#update_blacklist', :via => :post

  resources :roles
  match 'admin' => 'admin#index', :as => :admin
  match 'admin/update' => 'admin#update', :as => :admin_update


#######################
# CHILD URLS
#######################

  resources :children do
    collection do
      post :sync_unverified
      post :reindex
      get :advanced_search
      get :search
    end

    resources :attachments, :only => :show
    resource :duplicate, :only => [:new, :create]
  end

  match '/children-ids' => 'child_ids#all', :as => :child_ids
  match '/children/:id/photo/edit' => 'children#edit_photo', :as => :edit_photo, :via => :get
  match '/children/:id/photo' => 'children#update_photo', :as => :update_photo, :via => :put
  match '/children/:child_id/photos_index' => 'child_media#index', :as => :photos_index
  match '/children/:child_id/photos' => 'child_media#manage_photos', :as => :manage_photos
  match '/children/:child_id/audio(/:id)' => 'child_media#download_audio', :as => :child_audio
  match '/children/:child_id/photo/:photo_id' => 'child_media#show_photo', :as => :child_photo
  match '/children/:child_id/photo' => 'child_media#show_photo', :as => :child_legacy_photo
  match 'children/:child_id/select_primary_photo/:photo_id' => 'children#select_primary_photo', :as => :child_select_primary_photo, :via => :put
  match '/children/:child_id/resized_photo/:size' => 'child_media#show_resized_photo', :as => :child_legacy_resized_photo
  match '/children/:child_id/photo/:photo_id/resized/:size' => 'child_media#show_resized_photo', :as => :child_resized_photo
  match '/children/:child_id/thumbnail(/:photo_id)' => 'child_media#show_thumbnail', :as => :child_thumbnail
  match '/children' => 'children#index', :as => :child_filter


#######################
# API URLS
#######################

  namespace :api do
    controller :sessions do
      post :login
      post :register
      post :logout
    end

    resources :children do
      collection do
        get  :ids
        post :unverified
      end

      member do
        controller :child_media do
          get 'photo(/:photo_id)', :action => 'show_photo'
          get 'audio(/:audio_id)', :action => 'download_audio'
        end
      end
    end
  end

#######################
# FORM SECTION URLS
#######################

  resources :form_sections, :path => 'form_section', :controller => 'form_section' do
    collection do
      match 'save_order'
      match 'toggle'
      match 'published'
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

  match '/published_form_sections' => 'form_section#published', :as => :published_form_sections


#######################
# ADVANCED SEARCH URLS
#######################

  resources :advanced_search, :only => [:index, :new]
  match 'advanced_search/index' => 'advanced_search#index', :as => :advanced_search_index
  match 'advanced_search/export_data' => 'advanced_search#export_data', :as => :export_data_children, :via => :post


#######################
# LOGGING URLS
#######################

  resources :log_entries, :only => :index
  match '/children/:id/history' => 'child_histories#index', :as => :child_history, :via => :get
  match '/users/:id/history' => 'user_histories#index', :as => :user_history, :via => :get


#######################
# REPLICATION URLS
#######################

  resources :replications, :path => "/devices/replications" do
    collection do
      post :configuration
    end

    member do
      post :start
      post :stop
    end
  end

  resources :system_users, :path =>"/admin/system_users"

#######################
# REPORTING URLS
#######################
  resources :reports, :only => [ :index, :show ]

#######################
# TESTING URLS
#######################
  match 'database/delete_children' => 'database#delete_children', :via => :delete

end
