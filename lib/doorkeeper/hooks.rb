module Doorkeeper
  module Hooks
    extend ActiveSupport::Concern

    def before_action_hooks
      if hook_config.key? before_hook_key
        hook_config[before_hook_key].call(self)
      end
    end

    def after_action_hooks
      if hook_config.key? after_hook_key
        hook_config[after_hook_key].call(self)
      end
    end

    def hook_config
      Doorkeeper.configuration.action_hooks
    end

    def before_hook_key
      ('before_' + hook_stub).to_sym
    end

    def after_hook_key
      ('after_' + hook_stub).to_sym
    end

    def hook_stub
      self.class.name.demodulize.underscore
    end
  end
end
