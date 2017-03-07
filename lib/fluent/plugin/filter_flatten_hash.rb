module Fluent
  class FlattenHashFilter < Filter
    Plugin.register_filter('flatten_hash', self)

    require_relative 'flatten_hash_util'
    include FlattenHashUtil

    config_param :separator, :string, :default => '.'
    config_param :flatten_array, :bool, :default => true
    config_param :only_key, :string, :default => nil
    
    def configure(conf)
      super
      if !@only_key.nil?
        begin
          @only_key = @only_key.split(".")
        rescue => e
          raise Fluent::ConfigError, "only_key is illegal! only_key=#{@only_key}"
        end
      end
    end

    def filter(tag, time, record)
        if !@only_key.nil?
          item = record
          path = @only_key.dup
          prefix = path.pop

          path.delete_if do |k|
            if item.has_key?(k)
              item = item[k]
              true
            end
          end

          if !path.empty? or !item.has_key?(prefix)
            record
          else
            item.merge!(flatten_record(item[prefix], [prefix]))
            item.delete(prefix)
            record
          end
        else
          flatten_record(record, [])
        end
    end
  end if defined?(Filter)
end
