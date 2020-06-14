=begin
This is a port of the ID generation scheme used in hibernate TableHiLoGenerator -
=end
class Idgentable
  def self.getNextId
    HibernateIdGenerator.get_next_id(:id_gen_table)
  end
end

class HibernateIdGenerator

  def initialize(table_name)
    @max_lo = 50
    @lo = 0
    @hi = nil
    @table_name = table_name
  end


  def get_next_id
    if @hi == nil || @lo > @max_lo
      tmp_hi = get_next_id_hi
      @lo = tmp_hi == 0 ? 1 : 0
      @hi = tmp_hi * (@max_lo + 1) + @lo
    end
    @lo += 1
    @hi + @lo - 1
  end

  def self.get_next_id(table)
    generator = @@tables[table]
    if generator
      return generator.get_next_id
    end
    return nil
  end

  private

  def get_next_id_hi
    conn = ActiveRecord::Base.connection()
    count = 0
    new_base = nil
    #conn.execute("start transaction")
    conn.execute("set autocommit=0")
    while count == 0
      new_base = conn.execute("select next_value from #{@table_name} for update").first.first.to_i
      count = conn.update("UPDATE #{@table_name} SET next_value = #{new_base + 1} where next_value=#{new_base}")
    end
    conn.execute("commit")
    conn.execute("set autocommit=1")
    new_base
  end

  @@tables = {
      :id_gen_table => HibernateIdGenerator.new("idgentable"),
  }
end
