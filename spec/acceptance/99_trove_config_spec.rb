require 'spec_helper_acceptance'

describe 'basic trove_config resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      File <||> -> Trove_config <||>
      File <||> -> Trove_api_paste_ini <||>
      File <||> -> Trove_guestagent_config <||>

      file { '/etc/trove' :
        ensure => directory,
      }
      file { '/etc/trove/trove.conf' :
        ensure => file,
      }
      file { '/etc/trove/api-paste.ini' :
        ensure => file,
      }
      file { '/etc/trove/trove-guestagent.conf' :
        ensure => file,
      }

      trove_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      trove_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      trove_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      trove_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      trove_config { 'DEFAULT/thisshouldexist3' :
        value => ['foo', 'bar'],
      }

      trove_api_paste_ini { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      trove_api_paste_ini { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      trove_api_paste_ini { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      trove_api_paste_ini { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      trove_api_paste_ini { 'DEFAULT/thisshouldexist3' :
        value             => 'foo',
        key_val_separator => ':'
      }

      trove_guestagent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      trove_guestagent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      trove_guestagent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      trove_guestagent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/trove/trove.conf') do
      it { is_expected.to exist }
      it { is_expected.to contain('thisshouldexist=foo') }
      it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }
      it { is_expected.to contain('thisshouldexist3=foo') }
      it { is_expected.to contain('thisshouldexist3=bar') }

      describe '#content' do
        subject { super().content }
        it { is_expected.to_not match /thisshouldnotexist/ }
      end
    end

    describe file('/etc/trove/api-paste.ini') do
      it { is_expected.to exist }
      it { is_expected.to contain('thisshouldexist=foo') }
      it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }
      it { is_expected.to contain('thisshouldexist3:foo') }

      describe '#content' do
        subject { super().content }
        it { is_expected.to_not match /thisshouldnotexist/ }
      end
    end

    describe file('/etc/trove/trove-guestagent.conf') do
      it { is_expected.to exist }
      it { is_expected.to contain('thisshouldexist=foo') }
      it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }

      describe '#content' do
        subject { super().content }
        it { is_expected.to_not match /thisshouldnotexist/ }
      end
    end
  end
end
