class CreateIdgentable < ActiveRecord::Migration[6.0]
  def up
    execute("create table idgentable(next_value bigint)")
    execute("insert into idgentable values (1000)") #start it off at 1000.
  end
end
