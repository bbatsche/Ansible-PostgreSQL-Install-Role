require "serverspec"

shared_examples "postgres server" do
  describe "Server" do
    let(:subject) { service "postgresql" }

    it { should be_running }
  end
end

shared_examples "postgres client" do |version|
  describe "Client" do
    let(:subject) { command "psql --version" }

    it "is installed" do
      expect(subject.stdout).to match /\b#{Regexp.quote(version)}\.\d+/
    end

    include_examples "no errors"
  end
end

shared_examples "postgres security" do
  describe "Connecting without password" do
    describe "Admin user" do
      let(:subject) { command "psql -w -U vagrant postgres" }

      it "cannot connect" do
        expect(subject.stderr).to match /no password supplied/
        expect(subject.exit_status).not_to eq 0
      end
    end

    describe "Postgres user" do
      let(:subject) { command "psql -w -U postgres postgres" }

      it "cannot connect" do
        expect(subject.stderr).to match /Peer authentication failed/
        expect(subject.exit_status).not_to eq 0
      end
    end
  end

  describe "Connecting with password" do
    before(:context) do
      set :env, :PGPASSWORD => 'vagrant'
      set :docker_container_exec_options, :Env => ["PGPASSWORD=vagrant"]
    end

    describe "Admin user" do
      let(:subject) { command %Q{psql -wtA -U vagrant postgres -c "SELECT passwd FROM pg_shadow WHERE usename = 'vagrant'"} }

      it "has a hashed password" do
        expect(subject.stdout.strip).to match /\bmd5[[:xdigit:]]+/
      end

      include_examples "no errors"
    end
  end
end

shared_examples "postgres setting" do |variable, value|
  before(:context) do
    set :env, :PGPASSWORD => 'vagrant'
    set :docker_container_exec_options, :Env => ["PGPASSWORD=vagrant"]
  end

  describe variable do
    let(:subject) do
      result = command %Q|psql -wtA -U vagrant postgres -c "SELECT setting FROM pg_settings WHERE name = '#{variable}'"|
      result.stdout.strip
    end

    it "is #{value}" do
      expect(subject).to eq value
    end
  end
end
