module Marquee
  class ApplicationController < ActionController::Base
    include Marquee::VisitorIdentity
  end
end
