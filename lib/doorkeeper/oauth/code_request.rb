module Doorkeeper
  module OAuth
    class CodeRequest
      include Hooks

      attr_accessor :pre_auth, :resource_owner, :client

      def initialize(pre_auth, resource_owner)
        @pre_auth       = pre_auth
        @client         = pre_auth.client
        @resource_owner = resource_owner
      end

      def authorize
        before_action_hooks
        if pre_auth.authorizable?
          auth = Authorization::Code.new(pre_auth, resource_owner)
          auth.issue_token
          @response = CodeResponse.new pre_auth, auth
          after_action_hooks
          @response
        else
          @response = ErrorResponse.from_request pre_auth
        end
      end

      def deny
        pre_auth.error = :access_denied
        ErrorResponse.from_request pre_auth,
                                   redirect_uri: pre_auth.redirect_uri
      end
    end
  end
end
