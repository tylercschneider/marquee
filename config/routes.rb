Marquee::Engine.routes.draw do
  resources :leads, only: :create
  get "/:slug", to: "pages#show", as: :page
end
