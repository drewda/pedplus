$ ->
  $('.project-member-row input').change (event) ->
    rowNumber = event.currentTarget.id.match(/\d+/)[0]
    newState = this.checked
    if $(this).hasClass 'view-checkbox'
      if newState == false
        $("#project_project_members_attributes_#{rowNumber}_count").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_map").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_plan").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_manage").prop("checked", newState)
    else if $(this).hasClass 'count-checkbox'
      if newState == true
        $("#project_project_members_attributes_#{rowNumber}_view").prop("checked", newState)
      else if newState == false
        $("#project_project_members_attributes_#{rowNumber}_map").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_plan").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_manage").prop("checked", newState)
    else if $(this).hasClass 'map-checkbox'
      if newState == true
        $("#project_project_members_attributes_#{rowNumber}_view").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_count").prop("checked", newState)
      else if newState == false
        $("#project_project_members_attributes_#{rowNumber}_plan").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_manage").prop("checked", newState)
    else if $(this).hasClass 'plan-checkbox'
      if newState == true
        $("#project_project_members_attributes_#{rowNumber}_view").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_count").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_map").prop("checked", newState)
      else if newState == false
        $("#project_project_members_attributes_#{rowNumber}_manage").prop("checked", newState)
    else if $(this).hasClass 'manage-checkbox'
      if newState == true
        $("#project_project_members_attributes_#{rowNumber}_view").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_count").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_map").prop("checked", newState)
        $("#project_project_members_attributes_#{rowNumber}_plan").prop("checked", newState)