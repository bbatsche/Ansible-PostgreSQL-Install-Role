require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/install-postgresql.yml", ENV["TARGET_HOST"], {
      install_postgres: true,
      new_db_user:      "test_db_owner",
      new_db_pass:      "password",
      new_db_name:      "test_db",
    })
  end
end

context "PostgreSQL" do
  include_examples "postgres server"
  include_examples "postgres client", "9.6"
end

context "Database and owner" do
  before(:context) do
    set :env, :PGPASSWORD => 'password'
    set :docker_container_exec_options, :Env => ["PGPASSWORD=password"]
  end

  describe "Created database" do
    let(:subject) { command %Q{psql -wtA -U test_db_owner test_db -c "SELECT 'Connected'"} }

    it "can connect" do
      expect(subject.stdout.strip).to eq "Connected"
    end

    include_examples "no errors"
  end

  describe "System database" do
    let(:subject) { command %Q{psql -wtA -U test_db_owner test_db -c "SELECT * FROM pg_shadow"} }

    it "cannot query data" do
      expect(subject.stderr).to match /permission denied for relation pg_shadow/
      expect(subject.exit_status).not_to eq 0
    end
  end
end
