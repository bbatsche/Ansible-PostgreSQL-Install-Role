require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/install-postgresql.yml", ENV["TARGET_HOST"], {
      install_postgres: true,
      new_db_user:      "test_ro_user",
      new_db_pass:      "password",
      new_db_name:      "priv_test_db",
      new_db_priv:      { table: [ "SELECT" ], sequence: [ "SELECT" ] }
    })
  end
end

context "PostgreSQL" do
  include_examples "postgres server"
  include_examples "postgres client", "9.6"
end

describe "New user" do
  before(:context) do
    set :env, :PGPASSWORD => 'password'
    set :docker_container_exec_options, :Env => ["PGPASSWORD=password"]
  end

  let(:subject) { command %Q{psql -wtA -U test_ro_user priv_test_db -c "CREATE TABLE test_table (id integer PRIMARY KEY)"} }

  it "failed to create a table" do
    expect(subject.stderr).to match /permission denied for schema public/
    expect(subject.exit_status).not_to eq 0
  end
end
