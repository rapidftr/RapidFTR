RapidFTR::Application.routes.draw do
  resources :children do
    collection do
      get :advanced_search
      post :export_csv
      get :search
    end
    resource :history, :only => :show
    resources :attachments, :only => :show
    resource :duplicate, :only => [:new, :create]
  end

  resources :downloads do
    collection do
      post :children_data
      post :child_data
      post :children_record
      post :child_photo
    end
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
  match '/children/sync_unverified' => 'children#sync_unverified', :as => :sync_unverified_child, :via => :post

  resources :users do
    collection do
      get :change_password
      post :update_password
    end
  end
  match '/users/register_unverified' => 'users#register_unverified', :as => :register_unverified_user, :via => :post

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
  match 'form_section/enable' => 'form_section#enable', :as => :enable_form, :via => :post, :value => true
  match 'form_section/disable' => 'form_section#enable', :as => :disable_form, :value => false
  match '/form_section/save_form_order' => 'form_section#save_form_order', :as => :save_order
  match '/form_section/save_field_order' => 'form_section#save_field_order', :as => :save_order_single
  match '/active' => 'sessions#active', :as => :session_active
  resources :formsections, :controller => 'form_section' do
    additional_field_actions = FieldsController::FIELD_TYPES.inject({}) { |h, type| h["new_#{type}"] = :get; h }
    additional_field_actions[:move_up] = :post
    additional_field_actions[:move_down] = :post
    additional_field_actions[:delete] = :post
    additional_field_actions[:toggle_fields] = :post

    resources :fields, :controller => 'fields' do
      collection do
        additional_field_actions.each do |action, method|
          send method, action
        end
      end
    end
  end
  match 'form_section/:formsection_id/choose_field' => 'fields#choose', :as => :choose_field
  match '/published_form_sections' => 'publish_form_section#form_sections', :as => :published_form_sections
  resources :advanced_search, :only => [:index, :new]
  match 'advanced_search/index' => 'advanced_search#index', :as => :advanced_search_index
  resources :form_section
  resources :fields
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

  resources :system_users, :path =>"/admin/system_users"

  match 'database/delete_children' => 'database#delete_children', :via => :delete
  match '/' => 'home#index', :as => :root
end
