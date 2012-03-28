class Api::GateGroupSchedulesController < Api::ApiController
  def index
    @count_plan = CountPlan.find(params[:count_plan_id])

    # this is the hash that will be turned into the output JSON
    @schedule = Hash.new

    # loop through all the days, from start date to finish date
    @count_plan.start_date.upto(@count_plan.end_date) do |day|
      # convert the weekday number of this day
      twoLetterDay = ""
      case day.wday
      when 0
        twoLetterDay = "su"
      when 1
        twoLetterDay = "mo" 
      when 2
        twoLetterDay = "tu"
      when 3
        twoLetterDay = "we"
      when 4
        twoLetterDay = "th"
      when 5
        twoLetterDay = "fr"
      when 6
        twoLetterDay = "sa"
      end

      # create entry for the day in the hash
      @schedule[day] = Hash.new

      # find all GateGroups that include this weekday
      gateGroupsOnThisDay = @count_plan.gate_groups.where("days LIKE ?", "%#{twoLetterDay}%")

      # create a hash that lists GateGroup's by this day's hour
      gateGroupsOnThisDay.each do |gateGroup|
        gateGroup.hours.split(',').each do |hour|
          # create the array for each hour if necessary
          if not @schedule[day][hour].kind_of?(Array)
            @schedule[day][hour] = []
          end
          @schedule[day][hour].push gateGroup.id
        end
      end
    end

    # TODO: datetime, status, user_id, gate_group_id
    
    respond_to do |format|
      format.json { render :json => @schedule }
    end
  end
end