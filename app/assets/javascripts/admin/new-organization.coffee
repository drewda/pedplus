$ ->
  $('.organization-new #organization_kind').change (event) ->
    today = new XDate
    switch $(this).val()
      when 'free-trial'
        organizationMaxNumberOfUsers = 2
        organizationMaxNumberOfProjects = 1
        organizationDefaultMaxNumberOfCountingLocationsPerProject = 5
        organizationDefaultNumberOfCountingDayCreditsPerUser = 4
        organizationSubscriptionActiveUntil = today.addDays(30)
      when 'professional'
        organizationMaxNumberOfUsers = 10
        organizationMaxNumberOfProjects = 3
        organizationDefaultMaxNumberOfCountingLocationsPerProject = 15
        organizationDefaultNumberOfCountingDayCreditsPerUser = 7
        organizationSubscriptionActiveUntil = today.addYears(1)
      when 'academic-institution'
        organizationMaxNumberOfUsers = 100
        organizationMaxNumberOfProjects = 15
        organizationDefaultMaxNumberOfCountingLocationsPerProject = 25
        organizationDefaultNumberOfCountingDayCreditsPerUser = 4
        organizationSubscriptionActiveUntil = today.addYears(1)
      when 'student-pro'
        organizationMaxNumberOfUsers = 1
        organizationMaxNumberOfProjects = 1
        organizationDefaultMaxNumberOfCountingLocationsPerProject = 5
        organizationDefaultNumberOfCountingDayCreditsPerUser = 7
        organizationSubscriptionActiveUntil = today.addMonths(6)
    $('#organization_max_number_of_users').val organizationMaxNumberOfUsers
    $('#organization_max_number_of_projects').val organizationMaxNumberOfProjects
    $('#organization_default_max_number_of_counting_locations_per_project').val organizationDefaultMaxNumberOfCountingLocationsPerProject
    $('#organization_default_number_of_counting_day_credits_per_user').val organizationDefaultNumberOfCountingDayCreditsPerUser
    $('#organization_subscription_active_until_1i').val organizationSubscriptionActiveUntil.getFullYear()
    $('#organization_subscription_active_until_2i').val organizationSubscriptionActiveUntil.getMonth() + 1
    $('#organization_subscription_active_until_3i').val organizationSubscriptionActiveUntil.getDate()