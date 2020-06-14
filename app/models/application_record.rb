require 'idgentable'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_create :assign_id

  def assign_id
    self.id = Idgentable.getNextId unless self.id && self.id != 0
  end

end
