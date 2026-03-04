Marquee::Engine.routes.draw do
  namespace :admin do
    resources :experiments, only: [ :index, :show ]
    resources :leads, only: :index
    resources :pages, only: :index
  end

  resources :leads, only: :create
  get "/:slug", to: "pages#show", as: :page
end
