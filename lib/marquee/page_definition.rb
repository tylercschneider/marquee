module Marquee
  class PageDefinition
    attr_reader :slug, :sections

    def self.registry
      @registry ||= {}
    end

    def initialize(slug, &block)
      @slug = slug.to_s
      @_title = nil
      @_page_type = "custom"
      @_meta_title = nil
      @_meta_description = nil
      @sections = []
      instance_eval(&block) if block
    end

    def title(value = nil)
      value ? @_title = value : @_title
    end

    def page_type(value = nil)
      value ? @_page_type = value.to_s : @_page_type
    end

    def meta_title(value = nil)
      value ? @_meta_title = value : @_meta_title
    end

    def meta_description(value = nil)
      value ? @_meta_description = value : @_meta_description
    end
  end
end
