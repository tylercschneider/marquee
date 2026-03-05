Marquee::Engine.routes.draw do
  namespace :admin do
    resources :experiments, only: [ :index, :show ] do
      member do
        post :start
        post :pause
        post :resume
        post :complete
      end
    end
    resources :leads, only: :index
    resources :funnels, only: [ :index, :show ]
    resources :pages, only: :index
  end

  resources :leads, only: :create
  get "/:slug", to: "pages#show", as: :page
end
