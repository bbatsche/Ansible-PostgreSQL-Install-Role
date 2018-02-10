require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/install-postgresql.yml", ENV["TARGET_HOST"],{
      install_postgres: true,
      postgres_enable_network: true,
      postgres_max_connections: 22,
      postgres_shared_buffers_percent: 50,
      postgres_work_mem: "16MB",
      postgres_maintenance_work_mem: "80MB",
      postgres_checkpoint_timeout: "2h",
      postgres_min_wal_size: "192MB",
      postgres_max_wal_size: "1GB",
      postgres_checkpoint_completion_target: 0.6,
      postgres_effective_cache_percent: 90,
      timezone: "America/Phoenix"
    })
  end
end

context "PostgreSQL" do
  include_examples "postgres server"
  include_examples "postgres client", "9.6"
end

context "Settings" do
  before(:context) do
    set :env, :PGPASSWORD => 'vagrant'
    set :docker_container_exec_options, :Env => ["PGPASSWORD=vagrant"]
  end

  include_examples "postgres setting", "listen_addresses", "*"
  include_examples "postgres setting", "max_connections", "22"
  include_examples "postgres setting", "work_mem", (16 * 1024).to_s
  include_examples "postgres setting", "maintenance_work_mem", (80 * 1024).to_s
  include_examples "postgres setting", "checkpoint_timeout", (2 * 3600).to_s
  include_examples "postgres setting", "min_wal_size", (192 / 16).to_i.to_s
  include_examples "postgres setting", "max_wal_size", (1024 / 16).to_i.to_s # multiples of 16MB
  include_examples "postgres setting", "checkpoint_completion_target", "0.6"
  include_examples "postgres setting", "TimeZone", "America/Phoenix"

  describe "shared_buffers" do
    let(:subject) do
      result = command %Q|psql -wtA -U vagrant postgres -c "SELECT setting FROM pg_settings WHERE name = 'shared_buffers'"|
      result.stdout.strip.to_i
    end

    let(:totalMem) { host_inventory["memory"]["total"].to_i }

    it "is 50% of total memory" do
      expect(subject).to be_within(200).of ((totalMem * 0.5) / 8).to_i
    end
  end

  describe "effective_cache_size" do
    let(:subject) do
      result = command %Q|psql -wtA -U vagrant postgres -c "SELECT setting FROM pg_settings WHERE name = 'effective_cache_size'"|
      result.stdout.strip.to_i
    end

    let(:totalMem) { host_inventory["memory"]["total"].to_i }

    it "is 90% of total memory" do
      expect(subject).to be_within(200).of ((totalMem * 0.9) / 8).to_i
    end
  end
end
