#
# Git module, mostly just used to query the repo, could be used to tag?
#
module Celebrations
  class Git < Celebration

    def initialize(env)
      super env

      require 'grit'
    end

    def commit_tracker_progress(env)
      # Go through each finished story id we've seen in the git repo
      # and deliver each story that is marked as finished
      env.finished_store_ids.each do |story_id|

      end
    end

    def load_git_progress(env)
      repo = Grit::Repo.new(Dir.pwd)
      config = Grit::Config.new(repo)

      feature_branch = config.fetch('gitflow.prefix.feature', 'feature/')
      release_branch = config.fetch('gitflow.prefix.release', 'release/')
      puts "Feature branch: #{feature_branch}"
      puts "Release branch: #{release_branch}"

      # Find the last release
      latest_release = \
        repo.commits('master').find do |commit|
          commit.message =~ /\AMerge branch '#{release_branch}(\d+)/
        end
      latest_release_tag = $1

      puts "Commit: #{latest_release} #{latest_release.message}"
      previous_release = \
        repo.commits('master', 100).find do |commit|
          if commit.message =~ /\AMerge branch '#{release_branch}(\d+)/ 
            latest_release_tag != $1
          end
        end
      previous_release_tag = $1
      puts "Commit: #{previous_release} #{previous_release.message}"

      env.finished_story_ids = 
        repo.commits('develop').collect do |commit|
          $1 if commit.message =~ /\AMerge branch '#{feature_branch}(\d+)/
        end.compact
      puts env.finished_story_ids
    end

  end
end
