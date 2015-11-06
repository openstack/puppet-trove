require 'spec_helper'

describe 'trove::db::postgresql' do

  let :req_params do
    { :password => 'pw' }
  end

  let :pre_condition do
    'include postgresql::server'
  end

  context 'on a RedHat osfamily' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7.0',
        :concat_basedir         => '/var/lib/puppet/concat'
      })
    end

    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { is_expected.to contain_postgresql__server__db('trove').with(
        :user     => 'trove',
        :password => 'md5e12ef276d200761a0808f17a5b076451'
      )}
    end

  end

  context 'on a Debian osfamily' do
    let :facts do
      @default_facts.merge({
        :operatingsystemrelease => '7.8',
        :operatingsystem        => 'Debian',
        :osfamily               => 'Debian',
        :concat_basedir         => '/var/lib/puppet/concat'
      })
    end

    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { is_expected.to contain_postgresql__server__db('trove').with(
        :user     => 'trove',
        :password => 'md5e12ef276d200761a0808f17a5b076451'
      )}
    end

  end

end
