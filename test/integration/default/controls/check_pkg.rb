control 'nginx' do

  describe package('nginx') do
    it { should be_installed }
  end

  describe service('nginx') do
    it {should be_enabled}
    it {should be_running}
  end

  nginx_ver = ENV['TEST_NGINX_VER']

  if not [nil, '', 'auto'].include?(nginx_ver) then

    describe command('nginx -v') do
      its('stdout') { should match (/#{nginx_ver.split('-')[0]}/) }
    end

  end

end
