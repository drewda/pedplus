$ ->
  $('.organization-new #organization_kind').change (event) ->
    today = new XDate
    switch $(this).val()
      when 'free-trial'
        organizationMaxNumberOfUsers = 2
        organizationMaxNumberOfProjects = 1
        organizationDefaultMaxNumberOfGatesPerProject = 5
        organizationDefaultCountingDaysPerGate = 4
        organizationSubscriptionActiveUntil = today.addDays(30)
        organizationAllowedToExportProjects = false
      when 'professional'
        organizationMaxNumberOfUsers = 10
        organizationMaxNumberOfProjects = 3
        organizationDefaultMaxNumberOfGatesPerProject = 15
        organizationDefaultCountingDaysPerGate = 4
        organizationSubscriptionActiveUntil = today.addYears(1)
        organizationAllowedToExportProjects = true
      when 'academic-institution'
        organizationMaxNumberOfUsers = 100
        organizationMaxNumberOfProjects = 15
        organizationDefaultMaxNumberOfGatesPerProject = 50
        organizationDefaultCountingDaysPerGate = 4
        organizationSubscriptionActiveUntil = today.addYears(1)
        organizationAllowedToExportProjects = true
      when 'student-pro'
        organizationMaxNumberOfUsers = 1
        organizationMaxNumberOfProjects = 1
        organizationDefaultMaxNumberOfGatesPerProject = 5
        organizationDefaultCountingDaysPerGate = 4
        organizationSubscriptionActiveUntil = today.addMonths(6)
        organizationAllowedToExportProjects = true
    $('#organization_max_number_of_users').val organizationMaxNumberOfUsers
    $('#organization_max_number_of_projects').val organizationMaxNumberOfProjects
    $('#organization_default_max_number_of_gates_per_project').val organizationDefaultMaxNumberOfGatesPerProject
    $('#organization_default_counting_days_per_gate').val organizationDefaultCountingDaysPerGate
    $('#organization_subscription_active_until_1i').val organizationSubscriptionActiveUntil.getFullYear()
    $('#organization_subscription_active_until_2i').val organizationSubscriptionActiveUntil.getMonth() + 1
    $('#organization_subscription_active_until_3i').val organizationSubscriptionActiveUntil.getDate()
    $('#organization_allowed_to_export_projects').prop "checked", organizationAllowedToExportProjects