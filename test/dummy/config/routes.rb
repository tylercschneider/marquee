Rails.application.routes.draw do
  mount Marquee::Engine => "/admin/marquee"
  Marquee.routes(self)
end
