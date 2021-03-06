module HTTPI

  # = HTTPI::Adapter
  #
  # Manages the adapter classes. Currently supports:
  #
  # * httpclient
  # * curb
  # * em_http
  # * net/http
  module Adapter

    ADAPTERS = {}
    ADAPTER_CLASS_MAP = {}

    LOAD_ORDER = [:httpclient, :curb, :em_http, :net_http]

    class << self

      def register(name, adapter_class, deps)
        p "Adaptater::register"
        ADAPTERS[name] = { :class => adapter_class, :deps => deps }
        ADAPTER_CLASS_MAP[adapter_class] = name
      end

      def use=(adapter)
        p "Adaptater::use="
        
        return @adapter = nil if adapter.nil?

        validate_adapter! adapter
        load_adapter adapter
        @adapter = adapter
      end

      def use
        p "Adaptater::use"
        
        @adapter ||= default_adapter
      end

      def identify(adapter_class)
        p "Adaptater::identify"
        
        ADAPTER_CLASS_MAP[adapter_class]
      end

      def load(adapter)
        p "Adaptater::load"
        
        adapter ||= use

        validate_adapter!(adapter)
        load_adapter(adapter)
        ADAPTERS[adapter][:class]
      end

      def load_adapter(adapter)
        p "Adaptater::load_adapter"
        
        ADAPTERS[adapter][:deps].each do |dep|
          require dep
        end
      end

      private

      def validate_adapter!(adapter)
        p "Adaptater::validate_adapter!"
        
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless ADAPTERS[adapter]
      end

      def default_adapter
        p "Adaptater::default_adapter"
        
        LOAD_ORDER.each do |adapter|
          begin
            load_adapter adapter
            return adapter
          rescue LoadError
            next
          end
        end
      end

    end
  end
end
