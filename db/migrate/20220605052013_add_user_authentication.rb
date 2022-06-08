class AddUserAuthentication < ActiveRecord::Migration[6.0]
  def up
    execute("create table user_authentications(id bigint primary key, user_id bigint not null, auth_type int not null default 0, created_at timestamp null default null, updated_at timestamp null default null, external_identifier varchar(255), authentication_data mediumtext)")
    execute("create index user_authentications_by_user on user_authentications(user_id, auth_type)")
    execute("alter table users add column created_at timestamp null default null, add column update_at timestamp null default null")
  end

  def down
    execute("alter table users drop column created_at, drop column update_at")
    execute("drop table user_authentications")
  end
end
