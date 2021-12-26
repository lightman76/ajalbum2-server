require 'json'

namespace :user do
  desc 'Create the default user'
  task :create_default, [:user_name] => :environment do |t, args|
    un = args.user_name
    un = 'default' unless args.user_name
    u = User.connection.execute("insert into users values (0,'#{un}')")
    puts "Created user #{args.user_name} with id 0"
    #TODO: later user an operation to set this up properly and possibly change id
  end

  desc 'Add user'
  task :add_user, [:user_name] => :environment do |t, args|
    raise "NOT IMPLEMENTED"
  end
end