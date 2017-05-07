require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe CodeRequest do
    let(:pre_auth) do
      double(
        :pre_auth,
        client: double(:application, id: 9990),
        redirect_uri: 'http://tst.com/cb',
        scopes: nil,
        state: nil,
        error: nil,
        authorizable?: true
      )
    end

    let(:owner) { double :owner, id: 8900 }

    let(:hook_proc) { Proc.new { } }

    let(:hook_config) do
      {
        before_code_request: hook_proc,
        after_code_request: hook_proc
      }
    end

    subject do
      CodeRequest.new(pre_auth, owner)
    end

    it 'calls custom action hooks' do
      Doorkeeper.configuration.instance_variable_set('@action_hooks', hook_config )
      expect(hook_proc).to receive(:call).twice
      subject.authorize
    end

    it 'creates an access grant' do
      expect do
        subject.authorize
      end.to change { Doorkeeper::AccessGrant.count }.by(1)
    end

    it 'returns a code response' do
      expect(subject.authorize).to be_a(CodeResponse)
    end

    it 'does not create grant when not authorizable' do
      allow(pre_auth).to receive(:authorizable?).and_return(false)
      expect do
        subject.authorize
      end.to_not change { Doorkeeper::AccessGrant.count }
    end

    it 'returns a error response' do
      allow(pre_auth).to receive(:authorizable?).and_return(false)
      expect(subject.authorize).to be_a(ErrorResponse)
    end
  end
end
