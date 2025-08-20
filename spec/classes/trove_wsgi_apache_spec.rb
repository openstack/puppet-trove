require 'spec_helper'

describe 'trove::wsgi::apache' do

  shared_examples_for 'apache serving trove with mod_wsgi' do
    context 'with default parameters' do
      it { is_expected.to contain_class('trove::params') }
      it { is_expected.to contain_openstacklib__wsgi__apache('trove_wsgi').with(
        :bind_port                   => 8779,
        :group                       => 'trove',
        :path                        => '/',
        :priority                    => 10,
        :servername                  => 'foo.example.com',
        :ssl                         => false,
        :threads                     => 1,
        :user                        => 'trove',
        :workers                     => facts[:os_workers],
        :wsgi_daemon_process         => 'trove',
        :wsgi_process_group          => 'trove',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'app',
        :wsgi_script_source          => platform_params[:wsgi_script_source],
        :headers                     => nil,
        :request_headers             => nil,
        :custom_wsgi_process_options => {},
        :access_log_file             => nil,
        :access_log_pipe             => nil,
        :access_log_syslog           => nil,
        :access_log_format           => nil,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
      )}
    end

    context 'when overriding parameters' do
      let :params do
        {
          :servername                  => 'dummy.host',
          :bind_host                   => '10.42.51.1',
          :port                        => 12345,
          :ssl                         => true,
          :wsgi_process_display_name   => 'trove',
          :workers                     => 37,
          :custom_wsgi_process_options => {
            'python_path' => '/my/python/path',
          },
          :wsgi_script_dir             => '/var/lib/openstack/cgi-bin/trove',
          :wsgi_script_source          => '/my/path/app.wsgi',
          :headers                     => ['set X-XSS-Protection "1; mode=block"'],
          :request_headers             => ['set Content-Type "application/json"'],
          :vhost_custom_fragment       => 'Timeout 99'
        }
      end
      it { is_expected.to contain_class('trove::params') }
      it { is_expected.to contain_openstacklib__wsgi__apache('trove_wsgi').with(
        :bind_host                 => '10.42.51.1',
        :bind_port                 => 12345,
        :group                     => 'trove',
        :path                      => '/',
        :servername                => 'dummy.host',
        :ssl                       => true,
        :threads                   => 1,
        :user                      => 'trove',
        :workers                   => 37,
        :vhost_custom_fragment     => 'Timeout 99',
        :wsgi_daemon_process       => 'trove',
        :wsgi_process_display_name => 'trove',
        :wsgi_process_group        => 'trove',
        :wsgi_script_dir           => '/var/lib/openstack/cgi-bin/trove',
        :wsgi_script_file          => 'app',
        :wsgi_script_source        => '/my/path/app.wsgi',
        :headers                   => ['set X-XSS-Protection "1; mode=block"'],
        :request_headers           => ['set Content-Type "application/json"'],
        :custom_wsgi_process_options => {
          'python_path' => '/my/python/path',
        },
      )}
    end

    context 'with custom access logging' do
      let :params do
        {
          :access_log_format => 'foo',
          :access_log_syslog => 'syslog:local0',
          :error_log_syslog  => 'syslog:local1',
        }
      end

      it { should contain_openstacklib__wsgi__apache('trove_wsgi').with(
        :access_log_format => params[:access_log_format],
        :access_log_syslog => params[:access_log_syslog],
        :error_log_syslog  => params[:error_log_syslog],
      )}
    end

    context 'with access_log_file' do
      let :params do
        {
          :access_log_file => '/path/to/file',
        }
      end

      it { should contain_openstacklib__wsgi__apache('trove_wsgi').with(
        :access_log_file => params[:access_log_file],
      )}
    end

    context 'with access_log_pipe' do
      let :params do
        {
          :access_log_pipe => 'pipe',
        }
      end

      it { should contain_openstacklib__wsgi__apache('trove_wsgi').with(
        :access_log_pipe => params[:access_log_pipe],
      )}
    end

    context 'with error_log_file' do
      let :params do
        {
          :error_log_file => '/path/to/file',
        }
      end

      it { should contain_openstacklib__wsgi__apache('trove_wsgi').with(
        :error_log_file => params[:error_log_file],
      )}
    end

    context 'with error_log_pipe' do
      let :params do
        {
          :error_log_pipe => 'pipe',
        }
      end

      it { should contain_openstacklib__wsgi__apache('trove_wsgi').with(
        :error_log_pipe => params[:error_log_pipe],
      )}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers => 8,
        }))
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          {
            :wsgi_script_path   => '/usr/lib/cgi-bin/trove',
            :wsgi_script_source => '/usr/bin/trove-wsgi'
          }
        when 'RedHat'
          {
            :wsgi_script_path   => '/var/www/cgi-bin/trove',
            :wsgi_script_source => '/usr/lib/python3.9/site-packages/trove/cmd/app_wsgi.py',
          }

        end
      end
      it_configures 'apache serving trove with mod_wsgi'
    end
  end

end
