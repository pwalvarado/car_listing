CarListing::Application.routes.draw do
  root to: "listings#index"
  resources :listings

  namespace :api, defaults: {format: :json} do
    resources :listings, only: [:index, :show] do
      get :favorites, on: :collection
    end

    post '/listings/:listing_id/favorite', to: 'favorites#create', as: :favorite_listing
    delete '/listings/:listing_id/unfavorite', to: 'favorites#destroy', as: :unfavorite_listing

    resources :users, only: [:show] do
      get :listings, on: :member
      resource :contact_info, only: :show
    end

    resources :pics, only: :create
  end

  resources :users, only: [:new, :create, :edit, :update, :destroy] do
    get "activate", on: :collection

    member do
      post "resend_initial_activation_email", as: :resend_initial_activation_email_for
    end
  end

  get :dashboard, as: :dashboard, to: 'users#dashboard'

  resources :sellers, only: [:show], controller: 'users'

  get 'forgot_password', to: 'forgot_user_passwords#new', as: :forgot_password
  post 'forgot_password', to: 'forgot_user_passwords#create', as: :forgot_password
  get 'reset_password', to: 'forgot_user_passwords#reset_password', as: :reset_password
  put 'reset_password', to: 'forgot_user_passwords#update', as: :reset_password

  resource :user_session, only: [:new, :create, :destroy]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
