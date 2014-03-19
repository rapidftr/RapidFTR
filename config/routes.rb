RapidFTR::Application.routes.draw do

  get '/', to: 'home#index', :as => :root

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
  get 'login', to: 'sessions#new', :as => :login
  get 'logout', to: 'sessions#destroy', :as => :logout
  get '/active', to: 'sessions#active', :as => :session_active

  resources :user_preferences
  resources :password_recovery_requests, :only => [:new, :create]
  match 'password_recovery_request/:password_recovery_request_id/hide' => 'password_recovery_requests#hide', :as => :hide_password_recovery_request, :via => :delete

  resources :contact_information

  resources :devices
  match 'devices/update_blacklist' => 'devices#update_blacklist', :via => :post

  resources :roles
  get 'admin', to: 'admin#index', :as => :admin
  get 'admin/update', to: 'admin#update', :as => :admin_update


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

  get '/children-ids', to: 'child_ids#all', :as => :child_ids
  match '/children/:id/photo/edit' => 'children#edit_photo', :as => :edit_photo, :via => :get
  match '/children/:id/photo' => 'children#update_photo', :as => :update_photo, :via => :put
  get '/children/:child_id/photos_index', to: 'child_media#index', :as => :photos_index
  get '/children/:child_id/photos', to: 'child_media#manage_photos', :as => :manage_photos
  get '/children/:child_id/audio(/:id)', to: 'child_media#download_audio', :as => :child_audio
  get '/children/:child_id/photo/:photo_id', to: 'child_media#show_photo', :as => :child_photo
  get '/children/:child_id/photo', to: 'child_media#show_photo', :as => :child_legacy_photo
  match 'children/:child_id/select_primary_photo/:photo_id' => 'children#select_primary_photo', :as => :child_select_primary_photo, :via => :put
  get '/children/:child_id/resized_photo/:size', to: 'child_media#show_resized_photo', :as => :child_legacy_resized_photo
  get '/children/:child_id/photo/:photo_id/resized/:size', to: 'child_media#show_resized_photo', :as => :child_resized_photo
  get '/children/:child_id/thumbnail(/:photo_id)', to: 'child_media#show_thumbnail', :as => :child_thumbnail
  get '/children', to: 'children#index', :as => :child_filter


#######################
# API URLS
#######################

  namespace :api do
    controller :device do
      get 'is_blacklisted/:imei', :action => 'is_blacklisted'
    end

    controller :sessions, :defaults => {:format => :json} do
      post :login
      post :register
      post :logout
    end

    # CHILDREN

    resources :children do
      collection do
        delete "/destroy_all" => 'children#destroy_all'
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

    resources :enquiries, :defaults => {:format => :json} do
      collection do
        delete "/destroy_all" => 'enquiries#destroy_all'
      end
    end
  end

#######################
# FORM SECTION URLS
#######################

  resources :form_sections, :path => 'form_section', :controller => 'form_section' do
    collection do
      post 'save_order'
      post 'toggle'
      get 'published'
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

  get '/published_form_sections', to: 'form_section#published'


#######################
# ADVANCED SEARCH URLS
#######################

  resources :advanced_search, :only => [:index, :new]
  get 'advanced_search/index', to: 'advanced_search#index'
  match 'advanced_search/export_data' => 'advanced_search#export_data', :as => :export_data_children, :via => :post


#######################
# LOGGING URLS
#######################

  resources :system_logs, :only => :index
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

  resources :system_users, :path => "/admin/system_users"

#######################
# REPORTING URLS
#######################
  resources :reports, :only => [:index, :show]

#######################
# TESTING URLS
#######################
  match 'database/delete_children' => 'database#delete_children', :via => :delete

end
