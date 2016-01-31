require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook "playbooks/install-postgresql.yml"
  end
end

describe command("psql --version") do
  its(:stdout) { should match /\b9\.3\.\d+/ }

  its(:exit_status) { should eq 0 }
end

describe service('postgres') do
  it { should be_running }
end

# run before password is added to ENV
describe command("psql -w -U vagrant postgres") do
  its(:stderr) { should match /no password supplied/ }

  its(:exit_status) { should_not eq 0 }
end

describe command("psql -w -U postgres postgres") do
  its(:stderr) { should match /no password supplied/ }

  its(:exit_status) { should_not eq 0 }
end

describe command("sudo su - postgres -c 'psql -w'") do
  its(:stderr) { should match /no password supplied/ }

  its(:exit_status) { should_not eq 0 }
end

describe 'PSQL commands as vagrant' do
  before(:context) do
    set :env, :PGPASSWORD => 'vagrant'
  end

  describe command("psql -w -U vagrant postgres -c \"SELECT count(*) FROM pg_shadow WHERE usename = 'vagrant'\"") do
    its(:stdout) { should match /^\s*1\s*$/ }

    its(:exit_status) { should eq 0 }
  end

  describe command("psql -w -U vagrant postgres -c \"SELECT passwd FROM pg_shadow WHERE usename = 'vagrant'\"") do
    its(:stdout) { should match /s*md5/ }

    its(:exit_status) { should eq 0 }
  end
end
