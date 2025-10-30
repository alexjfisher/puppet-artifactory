# frozen_string_literal: true

Puppet::Type.newtype(:artifactory_access_settings) do
  @doc = <<-DOC
    @summary
      Generates a access.config.patch.yml file as needed using configuration values from `artifactory_access_setting` resources.
  DOC

  newparam(:path, namevar: true) do
    desc <<-DOC
      The access configuration directory.

      This is the directory where the existing config is expected to be found, as well as where any generated patch file will be created.
    DOC
  end

  autorequire(:file) do
    [patch_file_path]
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc <<-DOC
      Specifies the owner of the access.config.patch.yml file.
    DOC

    defaultto 'artifactory'
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc <<-DOC
      Specifies a permissions group of the access.config.patch.yml file.
      gid.
    DOC

    defaultto 'artifactory'
  end

  def patch_file_path
    "#{self[:path]}/access.config.patch.yml"
  end


  def access_settings
    @access_settings ||= catalog.resources.map { |resource|
      next unless resource.is_a?(Puppet::Type.type(:artifactory_access_setting))

      resource
    }.compact
  end

  def values_to_set
    values = access_settings.reduce({}) do |memo, res|
      memo[res[:name]] = res[:value] if config_patch_needed?(res[:name], res[:value])
      memo
    end

    debug "values to set #{values}"
    values
  end

  def current_config
    @current_config ||= begin
                          YAML.load_file("#{self[:path]}/access.config.latest.yml")
                        rescue Errno::ENOENT
                          info 'access.config.latest.yml not found. Treating as empty hash.'
                          {}
                        rescue StandardError => e
                          warning "Error reading #{self[:path]}/access.config.latest.yml #{e.inspect}"
                          # Should we raise here instead??
                          {}
                        end
  end

  def config_patch_needed?(setting, expected)
    path = setting.split('.')

    begin
      actual = current_config.dig(*path)
    rescue StandardError => e
      # We can't for example dig into `True` values
      warning e.inspect
      return true
    end

    # Artifactory seems to import Integers values and convert them to Strings.
    # If we're expecting an Integer and the config file has a String, we need to try to coerce it to an Integer before comparing
    expected != (expected.is_a?(Integer) && actual.is_a?(String) ? (Integer(actual) rescue actual): actual)
  end

  def undot_keys(settings)
    settings.each_with_object({}) do |(key, value), acc|
      *path, leaf = key.split('.')
      path.reduce(acc) { |h, k| h[k] ||= {} }[leaf] = value
    end
  end

  def should_content
    @should_content ||= begin
                          content = undot_keys(values_to_set)
                          if content == {}
                            nil
                          else
                            content.to_yaml
                          end
                        end
  end

  def generate
    file_opts = {
      ensure: :file,
      path: patch_file_path,
      owner: self[:owner],
      group: self[:group],
      mode: '0640',
    }

    [Puppet::Type.type(:file).new(file_opts)]
  end

  def eval_generate
    content = should_content

    catalog.resource("File[#{patch_file_path}]")[:content] = content unless content.nil?

    catalog.resource("File[#{patch_file_path}]")[:ensure] = :absent if content.nil?

    [catalog.resource("File[#{patch_file_path}]")]
  end
end
