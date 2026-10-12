module Marquee
  module HostRoutesHelper
    def method_missing(method, *args, **kwargs, &block)
      if host_route?(method)
        main_app.public_send(method, *args, **kwargs, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      host_route?(method) || super
    end

    private

    def host_route?(method) = method.end_with?("_path", "_url") && main_app.respond_to?(method)
  end
end
