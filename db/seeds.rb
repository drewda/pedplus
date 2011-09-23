unlimited_plan = Subscription.create(:name => "Unlimited",
                                     :uses_ped => true,
                                     :uses_sign => true,
                                     :max_users => '999',
                                     :max_projects => '999')

s3sol = Organization.create(:name => "Strategic Spatial Solutions, Inc.",
                            :slug => "s3sol",
                            :url => 'http://www.s3sol.com',
                            :address => '2150 Allston Way, Suite 280',
                            :city => "Berkeley",
                            :state => "CA",
                            :postal_code => '94704',
                            :country => "United States",
                            :subscription => unlimited_plan)
                            
drew = User.create(:first_name => "Drew", 
                   :last_name => "Dara-Abrams",
                   :email => 'drew@s3sol.com',
                   :password => 'changeme', 
                   :password_confirmation => 'changeme',
                   :organization => s3sol)