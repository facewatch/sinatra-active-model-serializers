module Sinatra
  SERIALIZERS_DEFAULT_PATH = './app/serializers'

  module JSON
    def initialize
      files_required
      super
    end

    def json(object, options={})
      options = options.merge(settings.active_model_serializers)
      options[:root] = options[:root].nil?
      begin
        options[:root] =
          if options[:root].is_a?(FalseClass)
            false
          elsif defined?(Mongoid) && object.is_a?(Mongoid::Criteria)
            options[:each_serializer] = options[:serializer]
            object.first.class.name.underscore.pluralize if options[:root] == true
          elsif defined?(ActiveRecord) && object.is_a?(ActiveRecord::Relation)
            options[:each_serializer] = options[:serializer]
            object.first.class.name.underscore.pluralize if options[:root] == true
          end
        rescue LoadError
      end

      serializer = ActiveModel::Serializer.serializer_for(object, options)

      if serializer
        serializer.new(object, options).to_json
      else
        object.to_json(options)
      end
    end

    def files_required
      return unless settings.serializers_path
      Dir["#{ settings.serializers_path }/**/*.rb"].flatten.sort.each do |file|
        require file
      end
    end
  end

  Base.set :active_model_serializers, {}
  Base.set :serializers_path, SERIALIZERS_DEFAULT_PATH
end
