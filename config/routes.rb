RapidFTR::Application.routes.draw do
  resources :children do
    collection do
      post :reindex
      get :advanced_search
      post :export_csv
      get :search
      post :export_photos_to_pdf
      post :sync_unverified
      put :sync_unverified
    end

    member do
      get :export_photo_to_pdf
    end
    
    resources :attachments, :only => :show
    resource :duplicate, :only => [:new, :create]
  end

  match '/children/:id/history' => 'child_histories#index', :as => :child_history, :via => :get
  match '/children-ids' => 'child_ids#all', :as => :child_ids
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

  resources :users do
    collection do
      get :change_password
      get :unverified
      post :update_password
    end
  end

  match '/users/register_unverified' => 'users#register_unverified', :as => :register_unverified_user, :via => :post
  match '/users/:id/history' => 'user_histories#index', :as => :user_history, :via => :get

  resources :user_preferences
  resources :devices
  match 'devices/update_blacklist' => 'devices#update_blacklist', :via => :post

  resources :roles
  match 'admin' => 'admin#index', :as => :admin
  match 'admin/update' => 'admin#update', :as => :admin_update


  resources :sessions, :except => :index
  resources :password_recovery_requests, :only => [:new, :create]
  match 'password_recovery_request/:password_recovery_request_id/hide' => 'password_recovery_requests#hide', :as => :hide_password_recovery_request, :via => :delete
  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match '/form_section/save_form_order' => 'form_section#save_form_order', :as => :save_order
  match '/form_section/toggle' => 'form_section#toggle', :as => :toggle
  match '/active' => 'sessions#active', :as => :session_active
  resources :form_section, :controller => 'form_section' do
    resources :fields, :controller => 'fields' do
      collection do
        post "save_order"
        post "delete"
        post "toggle_fields"
        post "change_form"
      end
    end
  end
  match 'form_section/:form_section_id/choose_field' => 'fields#choose', :as => :choose_field
  match '/published_form_sections' => 'publish_form_section#form_sections', :as => :published_form_sections
  match 'advanced_search/index' => 'advanced_search#index', :as => :advanced_search_index
  match 'advanced_search/export_data' => 'advanced_search#export_data', :as => :export_data_children, :via => :post
  resources :advanced_search, :only => [:index, :new]
  resources :form_sections, :controller => "form_section"
  resources :contact_information
  resources :highlight_fields do
    collection do
      post :remove
    end
  end

  resources :replications, :path => "/devices/replications" do
    collection do
      post :configuration
    end

    member do
      post :start
      post :stop
    end
  end

  resources :reports, :only => [ :index, :show ]

  resources :system_users, :path =>"/admin/system_users"

  match 'database/delete_children' => 'database#delete_children', :via => :delete
  match '/' => 'home#index', :as => :root

end
