Rails.application.routes.draw do
  
  devise_for :users
  
  namespace :api do
    namespace :v1, defaults:{format: 'json'} do

      get '/listing_categories/:category_id/children', to: "listing_categories#show_listing_category_children"
      post '/listing_categories/:category_id/children', to: "listing_categories#create_children"
      get  '/current_user_profile', to: "users#current_user_profile"
      post '/verify_sms_key', to: "users#verify_sms_key"
      post '/services/:service_id/service_timings', to: "services#create_timings"
      post '/services/:service_id/service_images', to: "services#create_images"
      delete '/services/:service_id/service_images', to: "services#destroy_images"
      get '/search', to: "search#search"
      get '/key', to: "users#get_key"
      get '/users/:user_id/services', to: 'users#user_services'
      get '/users/current_user_services', to: 'users#current_user_services'
      post '/chat/acknowledge', to: "chat#chat_acknowledge"
      post '/chat', to: "chat#send_message"
      get  '/services/:id/rating', to: "services#rating"
      resources :users
      resources :listing_categories
      resources :services do
        resources :service_ratings
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
