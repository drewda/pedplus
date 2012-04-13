FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "Organization ##{n}" }
    address "1 Main St."
    city "San Francisco"
    state "CA"
    country "United States"
    postal_code "94040"
    owns_pedcount true
    owns_pedplus false
    max_number_of_users 3
    max_number_of_projects 3
    time_zone "Pacific Time (US & Canada)"
    kind "professional"
    default_max_number_of_gates_per_project 4
    subscription_active_until { Date.today + 1.year }
    default_counting_days_per_gate 4
    extra_counting_day_credits_available 0
  end

  factory :user do
    # organization
    sequence(:first_name) { |n| "Person #{n}" }
    last_name "Doe"
    email "john@testorg.com"
    password "password"
    password_confirmation "password"
  end

  factory :project do
    # organization
    sequence(:name) { |n| "Project ##{n}" }
    kind "pedcount"
  end

  factory :project_member do
    # user
    # project
    view true
    manage true
    count true
    map true
    plan true
  end
end