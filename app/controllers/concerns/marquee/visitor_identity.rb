module Marquee
  module VisitorIdentity
    extend ActiveSupport::Concern

    included do
      before_action :ensure_visitor_token
    end

    def visitor_token
      if defined?(Ahoy) && respond_to?(:ahoy) && ahoy.visitor_token.present?
        ahoy.visitor_token
      else
        cookies[:marquee_vid] ||= { value: SecureRandom.uuid,
                                     expires: 1.year.from_now, httponly: true }
        cookies[:marquee_vid]
      end
    end

    private

    def ensure_visitor_token
      visitor_token
    end
  end
end
