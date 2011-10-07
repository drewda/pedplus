require "resque/tasks"

# load up the entire Rails stack
task "resque:setup" => :environment