require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/install-postgresql.yml", ENV["TARGET_HOST"], {
      install_postgres: true,
      new_db_user:      "test_db_admin",
      new_db_pass:      "password",
    })
  end
end

context "PostgreSQL" do
  include_examples "postgres server"
  include_examples "postgres client", "9.6"
end

describe "System database" do
  before(:context) do
    set :env, :PGPASSWORD => 'password'
    set :docker_container_exec_options, :Env => ["PGPASSWORD=password"]
  end

  let(:subject) { command %Q{psql -wtA -U test_db_admin postgres -c "SELECT count(*) FROM pg_roles"} }

  it "connected" do
    expect(subject.stdout).to match /\d+/
  end

  include_examples "no errors"
end
