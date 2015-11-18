Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :users, only: [] do
      resources :gift_cards, only: [] do
        collection do
          get :lookup
        end
      end
      collection do
        resources :gift_cards, only: [:index, :show]
      end
    end
  end
end
