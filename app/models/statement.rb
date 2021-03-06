require 'net/http'
require 'uri'
require 'json'
require 'awesome_print'

YT_CLIENT_ID = ENV['YT_CLIENT_ID']
YT_CLIENT_SECRET = ENV['YT_CLIENT_SECRET']
YT_REFRESH_TOKEN = ENV['YT_REFRESH_TOKEN']
YT_TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'
YT_VIDEOS_URL = 'https://www.googleapis.com/upload/youtube/v3/videos'
BOUNDARY = '¸.·´¯`·.´¯`·.¸¸.·´¯`·.¸><(((º>'

class Statement < ActiveRecord::Base
  def self._sync_columns; []; end      
  def _sync_columns; Statement._sync_columns; end  
  include DirtyColumns

  after_create :thanks_email_to_user
  
  belongs_to :user
  belongs_to :event_day
  belongs_to :campaign
  belongs_to :candidate

  default_scope { includes(:event_day).order("event_days.date desc").order("statements.created_at desc") } 
  scope :approved, -> { includes(:event_day)
                          .where(approved: true)
                          .where("youtube_url != ''")
                          .order("event_days.date desc") }

  accepts_nested_attributes_for :user, allow_destroy: false

  attr_reader :user_name, :event_name, :campaign_name, :candidate_name
  validate :validate_statement?
  acts_as_taggable
  acts_as_taggable_on :issue_tag
  
  
  def user_name
    u = self.user
    u ? u.desc : ''
  end
  
  def event_name
    ed = self.event_day
    return '' unless ed
    e = ed.event
    e ? e.title : ''
  end
  
  def campaign_name
    c = self.campaign
    c ? c.name : ''
  end
  
  def candidate_name
    c = self.candidate
    c ? c.person_name : ''
  end 
  
  def youtube_embed_url
    self.youtube_url ? self.youtube_url.gsub('watch?v=', 'embed/') : ''
  end
  
  def date
    self.event_day ? self.event_day.date : self.created_at 
  end
  
  def self.advance_search(candidate_name,location,from,to,iss_tag)
    statements = Statement.approved
    statements.select{|statement| ((statement.candidate.present? && candidate_name.present?) ? (statement.candidate.person_name.to_s.downcase.include? candidate_name.to_s.downcase) : false )or (statement.event_day.present? ? ( (statement.event_day.event.venue.try(:name).to_s.downcase.include? location.to_s.downcase)) : false) or (statement.date_range(from,to,statement.date.strftime("%d/%m/%Y"))) or statement.issue_tag_list.include?(iss_tag)}.uniq
  end

  def thanks_email_to_user
    VideoMailer.video_submission(user).deliver if user.present? && user.email.present?
  end

  def self.tag_search(tag_params)
    statements = Statement.approved
    statements.select{|statement| statement.tag_list.map(&:downcase).any? {|word| word.include? tag_params.downcase }}
  end

  def date_range(from,to,date)
    (from.empty? || to.empty?) ? false : (from.to_date..to.to_date).to_a.map{|d| d.strftime("%d/%m/%Y")}.include?(date)
  end

  private
    def validate_statement?
      if self.approved
        if self.candidate.blank? and self.event_day.blank?
          self.errors.add(:candidate, "Please select the candidate.")
          self.errors.add(:event_day, "Please select the event day.")
        elsif self.candidate.blank?
          self.errors.add(:candidate, "Please select the candidate.")
        elsif self.event_day.blank?
          self.errors.add(:event_day, "Please select the event day.")
        end
      end
    end
    
end