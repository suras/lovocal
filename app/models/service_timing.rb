class ServiceTiming
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :timings, type: Hash
  field :holidays, type: Array
  
  embedded_in :service

end
