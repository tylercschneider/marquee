Marquee::Engine.routes.draw do
  get "/:slug", to: "pages#show", as: :page
end
