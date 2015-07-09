require 'spec_helper'

describe 'trove::config' do

  let :params do
    { :trove_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :trove_taskmanager_config => {
        'DEFAULT/foo2' => { 'value'  => 'fooValue' },
        'DEFAULT/bar2' => { 'value'  => 'barValue' },
        'DEFAULT/baz2' => { 'ensure' => 'absent' }
      },
      :trove_conductor_config => {
        'DEFAULT/foo2' => { 'value'  => 'fooValue' },
        'DEFAULT/bar2' => { 'value'  => 'barValue' },
        'DEFAULT/baz2' => { 'ensure' => 'absent' }
      },
      :trove_guestagent_config => {
        'DEFAULT/foo2' => { 'value'  => 'fooValue' },
        'DEFAULT/bar2' => { 'value'  => 'barValue' },
        'DEFAULT/baz2' => { 'ensure' => 'absent' }
      },
      :trove_api_paste_ini => {
        'DEFAULT/foo2' => { 'value'  => 'fooValue' },
        'DEFAULT/bar2' => { 'value'  => 'barValue' },
        'DEFAULT/baz2' => { 'ensure' => 'absent' }
      }
    }
  end

  it 'configures arbitrary trove configurations' do
    is_expected.to contain_trove_config('DEFAULT/foo').with_value('fooValue')
    is_expected.to contain_trove_config('DEFAULT/bar').with_value('barValue')
    is_expected.to contain_trove_config('DEFAULT/baz').with_ensure('absent')
  end

  it 'configures arbitrary trove taskmanager configurations' do
    is_expected.to contain_trove_taskmanager_config('DEFAULT/foo2').with_value('fooValue')
    is_expected.to contain_trove_taskmanager_config('DEFAULT/bar2').with_value('barValue')
    is_expected.to contain_trove_taskmanager_config('DEFAULT/baz2').with_ensure('absent')
  end

  it 'configures arbitrary trove conductor configurations' do
    is_expected.to contain_trove_conductor_config('DEFAULT/foo2').with_value('fooValue')
    is_expected.to contain_trove_conductor_config('DEFAULT/bar2').with_value('barValue')
    is_expected.to contain_trove_conductor_config('DEFAULT/baz2').with_ensure('absent')
  end

  it 'configures arbitrary trove guestagent configurations' do
    is_expected.to contain_trove_guestagent_config('DEFAULT/foo2').with_value('fooValue')
    is_expected.to contain_trove_guestagent_config('DEFAULT/bar2').with_value('barValue')
    is_expected.to contain_trove_guestagent_config('DEFAULT/baz2').with_ensure('absent')
  end

  it 'configures arbitrary trove api-paste configurations' do
    is_expected.to contain_trove_api_paste_ini('DEFAULT/foo2').with_value('fooValue')
    is_expected.to contain_trove_api_paste_ini('DEFAULT/bar2').with_value('barValue')
    is_expected.to contain_trove_api_paste_ini('DEFAULT/baz2').with_ensure('absent')
  end
end
