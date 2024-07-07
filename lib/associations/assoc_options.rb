require "active_support/core_ext/string"

class AssociationOption
  attr_reader :primary_key, :foreign_key, :class_name

  def initialize(primary_key, foreign_key, class_name)
    @primary_key = primary_key
    @foreign_key = foreign_key
    @class_name = class_name
  end
end

class BelongsTo < AssociationOption
  def initialize(association_name, **optional_hash)
    primary_key = optional_hash[:primary_key] ? optional_hash[:primary_key].to_s : "id"
    foreign_key = optional_hash[:foreign_key].to_s
    class_name = optional_hash[:class_name].to_s.singularize
    super(foreign_key, primary_key, class_name)
  end
end

class HasManyOptions < AssociationOption
  def initialize(association_name, **optional_hash)
    primary_key = optional_hash[:primary_key] ? optional_hash[:primary_key].to_s : "id"
    foreign_key = optional_hash[:foreign_key].to_s
    class_name = optional_hash[:class_name].to_s.singularize
    super(primary_key, foreign_key, class_name)
  end
end