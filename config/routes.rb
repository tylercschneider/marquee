Marquee::Engine.routes.draw do
  namespace :admin do
    resources :experiments, only: [ :index, :show ]
  end

  resources :leads, only: :create
  get "/:slug", to: "pages#show", as: :page
end
