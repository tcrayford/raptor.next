require "tilt"

module Raptor
  class FindsLayouts
    LAYOUT_FILENAME = 'layout.html.erb'
    def self.find(path)
      in_same_dir = File.join('views', path, LAYOUT_FILENAME)
      in_root_dir = File.join('views', LAYOUT_FILENAME)
      if File.exist?(in_same_dir)
        Layout.from_path(in_same_dir)
      elsif File.exist?(in_root_dir)
        Layout.from_path(in_root_dir)
      else
        NullLayout
      end
    end
  end

  class NullLayout
    def self.render(inner, context)
      inner.render(context)
    end
  end

  class Layout
    attr_reader :tilt
    def initialize(tilt)
      @tilt = tilt
    end

    def self.from_path(path)
      new(Tilt.new(path))
    end

    def ==(other)
      other.is_a?(Layout) &&
        other.tilt == tilt
    end

    def render(inner, context)
      rendered = inner.render(context)
      @tilt.render(context) { rendered }
    end
  end

  class ViewContext < BasicObject
    def initialize(presenter, injector)
      @presenter = presenter
      @areas = {}
      @injector = injector
    end

    def content_for(name, &block)
      if block
        @areas[name] ||= []
        @areas[name] << block.call 
      else
        @areas[name].join
      end
    end

    def inject(name)
      ::Raptor.log("Injecting #{name.inspect} into view")
      @injector.inject_name(name)
    end

    def method_missing(name, *args, &block)
      @presenter.send(name, *args, &block)
    end
  end

  class Template
    def initialize(tilt)
      @tilt = tilt
    end

    def render(presenter)
      @tilt.render(presenter)
    end

    def self.from_path(template_path)
      path = full_template_path(template_path)
      tilt = Tilt.new(path)
      new(tilt)
    end

    def self.full_template_path(template_path)
      template_path = "/#{template_path}" unless template_path =~ /^\//
      "views#{template_path}"
    end
  end
end
