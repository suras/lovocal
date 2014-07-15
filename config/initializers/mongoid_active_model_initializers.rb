# config/initializers/
Mongoid::Document.send(:include, ActiveModel::SerializerSupport)
Mongoid::Criteria.delegate(:active_model_serializer, to: :to_a)
ActiveModel::Serializer.root = false
ActiveModel::ArraySerializer.root = false # for array serializer