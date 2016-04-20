require 'spec_helper'

describe 'trove::db' do

  shared_examples 'trove::db' do

    context 'with default parameters' do

      it { is_expected.to contain_trove_config('database/connection').with_value('sqlite:////var/lib/trove/trove.sqlite').with_secret(true) }
      it { is_expected.to contain_trove_config('database/idle_timeout').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_trove_config('database/min_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_trove_config('database/max_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_trove_config('database/max_overflow').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_trove_config('database/max_retries').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_trove_config('database/retry_interval').with_value('<SERVICE DEFAULT>') }

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql+pymysql://trove:trove@localhost/trove',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '21',
          :database_max_retries    => '11',
          :database_max_overflow   => '21',
          :database_retry_interval => '11', }
      end

      it { is_expected.to contain_trove_config('database/connection').with_value('mysql+pymysql://trove:trove@localhost/trove').with_secret(true) }
      it { is_expected.to contain_trove_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_trove_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_trove_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_trove_config('database/max_pool_size').with_value('21') }
      it { is_expected.to contain_trove_config('database/max_overflow').with_value('21') }
      it { is_expected.to contain_trove_config('database/retry_interval').with_value('11') }
    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection     => 'mysql://trove:trove@localhost/trove', }
    end

      it { is_expected.to contain_package('python-mysqldb').with(:ensure => 'present') }
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://trove:trove@localhost/trove', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'redis://trove:trove@localhost/trove', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        { :database_connection     => 'foo+pymysql://trove:trove@localhost/trove', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => 'jessie',
      })
    end

    it_configures 'trove::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://trove:trove@localhost/trove', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('db_backend_package').with(
          :ensure => 'present',
          :name   => 'python-pymysql',
          :tag    => 'openstack',
        )
      end
    end
  end

  context 'on Redhat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7.1',
      })
    end

    it_configures 'trove::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://trove:trove@localhost/trove', }
      end

      it { is_expected.not_to contain_package('db_backend_package') }
    end
  end

end
