require 'idgentable'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_create :assign_id

  def assign_id
    self.id = Idgentable.getNextId unless self.id && self.id != 0
  end

  # Get is like find(id) but returns nil if the object is not found rather than raising an error
  def self.get(*ids)
    ids = [ids].flatten.collect { |id| (id.nil? || (id == '')) ? nil : id.to_i }.compact
    return nil if ids.length == 0
    if ids.length < 2
      return self.where(:id => ids[0]).first
    else
      return self.where(:id => ids).to_a
    end
  end
end
