module Marquee
  class ApplicationController < ActionController::Base
    include Marquee::VisitorIdentity
    helper Marquee::HostRoutesHelper
  end
end
