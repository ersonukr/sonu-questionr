module SearchHelper

  def search_filter(statement)
    #if all params present
    if params[:q].present? && params[:v].present? && from_to? && venue(statement) && params[:i_tag].present?
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase and statement.event_day.event.venue.name.downcase.include? params[:v].downcase and date_range(params[:from],params[:to],statement) and statement.issue_tag_list.include?(params[:i_tag])
    #if any three params present
    elsif params[:q].present? && params[:v].present? && from_to? && venue(statement)
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase and statement.event_day.event.venue.name.downcase.include? params[:v].downcase and date_range(params[:from],params[:to],statement)
    elsif params[:q].present? && params[:v].present? && venue(statement) && params[:i_tag].present?
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase and statement.event_day.event.venue.name.downcase.include? params[:v].downcase and statement.issue_tag_list.include?(params[:i_tag])
    elsif params[:q].present? && from_to? && params[:i_tag].present?
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase and  date_range(params[:from],params[:to],statement) and statement.issue_tag_list.include?(params[:i_tag])
    elsif params[:v].present? && from_to? && venue(statement) && params[:i_tag].present?
      statement.event_day.event.venue.name.downcase.include? params[:v].downcase and date_range(params[:from],params[:to],statement) and statement.issue_tag_list.include?(params[:i_tag])
        
    #if any two params present
    elsif params[:q].present? && params[:i_tag].present?
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase and  statement.issue_tag_list.include?(params[:i_tag])
    elsif params[:q].present? && params[:v].present? && venue(statement)
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase and statement.event_day.event.venue.name.downcase.include? params[:v].downcase
    elsif params[:q].present? && from_to? 
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase and date_range(params[:from],params[:to],statement)
    elsif params[:i_tag].present? && params[:v].present? && venue(statement) 
      statement.issue_tag_list.include?(params[:i_tag]) and statement.event_day.event.venue.name.downcase.include? params[:v].downcase
    elsif params[:i_tag].present? && from_to? 
      statement.issue_tag_list.include?(params[:i_tag]) and date_range(params[:from],params[:to],statement)
    elsif params[:v].present? && from_to? && venue(statement)
      statement.event_day.event.venue.name.downcase.include? params[:v].downcase and date_range(params[:from],params[:to],statement)  
    
    #if any one params present
    elsif params[:q].present?
      statement.candidate.person_name.to_s.downcase.include? params[:q].downcase
    elsif params[:v].present? && venue(statement)
      statement.event_day.event.venue.name.downcase.include? params[:v].downcase
    elsif from_to?
      date_range(params[:from],params[:to],statement)
    elsif params[:i_tag].present?
      statement.issue_tag_list.include?(params[:i_tag])
    else
      false
    end
  end

  def candidate_filter(statement)
    #if all params present
    if params[:candidate_name].present? && params[:candidate_issue].present? && params[:state].present? && params[:date].present?
      statement.issue_tag_list.include?(params[:candidate_issue]) and statement.date.strftime("%d/%m/%Y").include? params[:date] and venue(statement) && (statement.event_day.event.venue.state.downcase.include? params[:state].downcase)
    #if any three params present
    elsif params[:candidate_name].present? && params[:candidate_issue].present? && params[:state].present?
      statement.issue_tag_list.include?(params[:candidate_issue]) and venue(statement) && (statement.event_day.event.venue.state.downcase.include? params[:state].downcase)
    elsif params[:candidate_name].present? && params[:candidate_issue].present? && params[:date].present?
      statement.issue_tag_list.include?(params[:candidate_issue]) and statement.date.strftime("%d/%m/%Y").include? params[:date]
    elsif params[:candidate_name].present? && params[:state].present? && params[:date].present?
      statement.date.strftime("%d/%m/%Y").include? params[:date] and venue(statement) && (statement.event_day.event.venue.state.downcase.include? params[:state].downcase)
  
    #if any two params present
    elsif params[:candidate_name].present? && params[:candidate_issue].present?
      statement.issue_tag_list.include?(params[:candidate_issue])
    elsif params[:candidate_name].present? && params[:state].present?
      venue(statement) && (statement.event_day.event.venue.state.downcase.include? params[:state].downcase)
    elsif params[:candidate_name].present? && params[:date].present?
      statement.date.strftime("%d/%m/%Y").include? params[:date]
    #if any one params present
    elsif params[:candidate_name].present?
      true
    else
      false
    end
  end


  def venue(statement)
    statement.event_day.present? && statement.event_day.event.present? && statement.event_day.event.venue.present?
  end

  def event_day(statement)
    statement.event_day.present?
  end

  def from_to?
    params[:from].present? && params[:to].present?
  end

  def date_range(from,to,statement)
    (from.to_date..to.to_date).to_a.map{|d| d.strftime("%d/%m/%Y")}.include?(statement.date.strftime("%d/%m/%Y"))
  end

  def candidate_list
    Candidate.approved_videos.map{ |u| [u.person_name, u.person_name] }
  end
end
