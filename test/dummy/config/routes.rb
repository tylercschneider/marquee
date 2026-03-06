Rails.application.routes.draw do
  mount Marquee::Engine => "/admin/marquee"
  get "tracking-test", to: "tracking_test#show"
  post "lead-capture-test", to: "lead_capture_test#create"
  Marquee.routes(self)
end
