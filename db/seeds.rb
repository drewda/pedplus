require 'highline'

organization_name = ask("Name of your organization?  ")
user_first_name = ask("Your first name?  ")
user_last_name = ask("Your last name?  ")
user_email_address = ask("Your e-mail address?  ")
user_password = ask("Set your password:  ") { |q| q.echo = "x" }

org = Organization.create(:name => organization_name,
                            :slug => organization_name.parameterize,
                            :country => "United States",
                            :owns_pedcount => true,
                            :owns_pedplus => false,
                            :time_zone => 'Pacific Time (US & Canada)',
                            :default_max_number_of_gates_per_project => 1000,
                            :subscription_active_until => Date.today + 1.year,
                            :default_counting_days_per_gate => 4,
                            :extra_counting_day_credits_available => 1000,
                            :allowed_to_export_projects => true,
                            :kind => 'professional',
                            :organization_manager => true,
                            :s3sol_admin => true)
                            
user = User.create(:first_name => user_first_name,
                   :last_name => user_last_name,
                   :email => user_email_address,
                   :password => user_password,
                   :password_confirmation => user_password,
                   :organization => org)
