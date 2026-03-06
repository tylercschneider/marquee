Rails.application.routes.draw do
  mount Marquee::Engine => "/admin/marquee"
  get "tracking-test", to: "tracking_test#show"
  Marquee.routes(self)
end
