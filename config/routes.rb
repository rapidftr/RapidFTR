ActionController::Routing::Routes.draw do |map|
  map.resources( 
    :children, 
     :collection => { :search => :get, :photo_pdf => :post } ) do |child|
    child.resource :history, :only => :show
    child.resources :attachments, :only => :show
  end
  map.resources :users
  map.admin 'admin', :controller=>"admin", :action=>"index"
  map.resources :sessions, :except => :index


  map.login 'login', :controller=>'sessions',:action =>'new'
  map.logout 'logout', :controller=>'sessions',:action =>'destroy'


  
  map.resources :formsections, :controller=>'form_section' do |form_section|
    field_types = %w{text_field textarea check_box select_drop_down}
    additional_field_actions = field_types.inject({}){ |h,type| h["new_#{type}"] = :get; h }
    additional_field_actions[:new] = :get
    additional_field_actions[:move_up] = :post
    additional_field_actions[:move_down] = :post
    form_section.resources(
      :fields,
      :controller => 'fields',
      :collection => additional_field_actions )
  end

  map.resources :form_section

  map.resources :fields

  map.root :controller => 'children', :action => :index
end
