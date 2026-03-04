module Marquee
  class PageDefinition
    attr_reader :slug

    def self.registry
      @registry ||= {}
    end

    def self.sync!(version: nil)
      registry.each_value do |defn|
        page = Page.find_or_initialize_by(slug: defn.slug)
        attrs = {
          title: defn.title,
          page_type: defn.page_type,
          meta_title: defn.meta_title,
          meta_description: defn.meta_description,
          template_path: defn.template_path
        }
        new_record = page.new_record?
        page.update!(attrs)

        if version && !new_record
          page.bump_version!(version)
        end
      end
    end

    def initialize(slug, &block)
      @slug = slug.to_s
      @_title = nil
      @_page_type = "custom"
      @_meta_title = nil
      @_meta_description = nil
      @_template_path = nil
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

    def template_path(value = nil)
      value ? @_template_path = value : @_template_path
    end
  end
end
