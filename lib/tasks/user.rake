require 'json'

namespace :user do
  desc 'Create the default user'
  task :create_default, [:user_name] => :environment do |t, args|
    un = args.user_name
    un = 'default' unless args.user_name
    u = User.connection.execute("insert into users values (0,'#{un}', now(), now())")
    puts "Created user #{args.user_name} with id 0"
    #TODO: later user an operation to set this up properly and possibly change id
  end

  desc 'Add user'
  task :add_user, [:user_name] => :environment do |t, args|
    raise "NOT IMPLEMENTED"
  end

  desc 'Set password for user'
  task :set_password, [:user_name, :password] => :environment do |t, args|
    raise "Must specify username" unless args.user_name
    raise "Must specify password" unless args.password

    op = ::User::Operation::CreatePassword.(params: { user: args.user_name, new_password: args.password })
    unless op.success?
      puts "Failed to set password: #{op['contract.default'].errors.inspect}"
      raise "Failed"
    end
    puts "Successfully set password for #{args.user_name}"
  end
end