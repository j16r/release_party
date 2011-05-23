#
# Pivotal tracker celebration module, supports tasks:
#
# Obtain progress
# Deliver features
#
module Celebrations
  class PivotalTracker < Celebration
    include Announce
    
    attr :project_id, :project_api_key
    attr :project

    def initialize(env)
      super env
      arguments_required(:project_id, :project_api_key)

      require 'pivotal-tracker'

      @project_id = environment.project_id
      @project_api_key = environment.project_api_key

      ::PivotalTracker::Client.token = environment.project_api_key

      begin
        @project = ::PivotalTracker::Project.find(environment.project_id)
      rescue RestClient::Request::Unauthorized => e
        announce 'Unable to authenticate with pivotal, perhaps your API key is wrong.' +
          "Message: #{e.message}"
      end
    end

    def before_deploy
      environment.finished_stories = finished_stories
      environment.known_bugs = known_bugs
    end

    def after_deploy
      # Deliver all finished stories if the deliver_finished flag is set
      if environment.deliver_finished? && environment.deliver_finished
        finished_stories.each do |story|
          story.update(:current_state => 'delivered')
        end
      end
    end

  private #######################################################################

    def finished_stories
      project.stories.all(:state => 'finished')
    end

    def known_bugs
      project.stories.all(:state => ['unstarted', 'started'], :story_type => 'bug')
    end

  end
end
