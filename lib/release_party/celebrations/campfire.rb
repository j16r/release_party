#
# Campfire announcer
#
module Celebrations
  class Campfire < Celebration

    attr :campfire

    def initialize(env)
      super env
      arguments_required(:campfire_account, :campfire_room, :campfire_token)

      require 'tinder'

      ssl = environment.campfire_ssl
      @campfire = ::Tinder::Campfire.new \
        environment.campfire_account,
        :token => environment.campfire_token,
        :ssl => ssl
      @campfire.find_room_by_name(environment.campfire_room)
    end

    def after_deploy
      @campfire.speak environment.campfire_begin_message
    end

    def before_deploy
      @campfire.speak environment.campfire_after_message
    end

  end
end
