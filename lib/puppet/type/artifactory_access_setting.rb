# frozen_string_literal: true

Puppet::Type.newtype(:artifactory_access_setting) do
  newparam(:name, namevar: true) do
    desc 'Name of setting in dotted notation.'
  end

  newparam(:value) do
    desc 'The value of the setting'
  end
end
