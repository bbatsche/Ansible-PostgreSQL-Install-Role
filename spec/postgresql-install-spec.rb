require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook "playbooks/install-postgresql.yml", ENV["TARGET_HOST"], install_postgres: true
  end
end

context "PostgreSQL" do
  include_examples "postgres server"
  include_examples "postgres client", "9.6"
end

context "Security" do
  include_examples "postgres security"
end
