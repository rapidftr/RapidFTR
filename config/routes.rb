ActionController::Routing::Routes.draw do |map|
  map.resources( 
    :children, 
     :collection => { :search => :get, :photo_pdf => :post } ) do |child|
    child.resource :history, :only => :show
    child.resources :attachments, :only => :show
  end
  map.resources :users
  map.resources :sessions, :except => :index

  map.login 'login', :controller=>'sessions',:action =>'new'
  map.logout 'logout', :controller=>'sessions',:action =>'destroy'

  map.resources 'formsection', :controller=>'form_section'
  map.manage_fields 'formsection/:formsection/fields', :controller=>'form_section', :action=>:index  #todo: where does this go?
  map.resources 'fields', :controller=>'fields'
  map.connect 'fields/new', :controller=>'fields'  , :action=>:new
  map.connect 'fields/new/:fieldtype', :controller=>'fields'  , :action=>:new

  # Field routes
  map.new_field 'fields/:fieldtype/new', :controller=>'fields'  , :action=>:new
  map.new_textarea_field '/fields/textarea/new/', :controller=>'fields', :action=>:new, :fieldtype=>:textarea
  map.new_text_field_field '/fields/text_field/new/', :controller=>'fields', :action=>:new, :fieldtype=>:textfield
  map.new_check_box_field '/fields/check_box/new/', :controller=>'fields', :action=>:new, :fieldtype=>:check_box
  map.new_select_drop_down_field '/fields/select_drop_down/new/', :controller=>'fields', :action=>:new, :fieldtype=>:select_drop_down

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
#  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
