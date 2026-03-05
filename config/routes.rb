Marquee::Engine.routes.draw do
  scope module: :admin do
    resources :experiments, only: [ :index, :show ] do
      member do
        post :start
        post :pause
        post :resume
        post :complete
      end
    end
    resources :leads, only: :index, as: :admin_leads
    resources :funnels, only: [ :index, :show ]
    resources :pages, only: :index
  end
end
