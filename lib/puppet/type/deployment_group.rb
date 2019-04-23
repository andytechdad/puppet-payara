$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'ipaddr'

Puppet::Type.newtype(:deployment_group) do
  @doc = "Manage Glassfish Deployment Group"

  ensurable

  newparam(:deployment_groupname) do
    desc "The Glassfish Deployment Group Name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid deployment-group name." % value
      end
    end
  end

  newparam(:dashost) do
    desc "The Glassfish DAS hostname."
  end

  newparam(:dasport) do
    desc "The Glassfish DAS port. Default: 4848"
    defaultto '4848'

    validate do |value|
      raise ArgumentError, "%s is not a valid das port." % value unless value =~ /^\d{4,5}$/
    end

    munge do |value|
      case value
      when String
        if value =~ /^[-0-9]+$/
          value = Integer(value)
        end
      end

      return value
    end
  end

  newparam(:asadminuser) do
    desc "The internal Glassfish user asadmin uses. Default: admin"
    defaultto 'admin'

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid asadmin user name." % value
      end
    end
  end

  newparam(:passwordfile) do
    desc "The file containing the password for the user."
  end

  newparam(:user) do
    desc "The user to run the command as."

    validate do |value|
      unless Puppet.features.root?
        self.fail "Only root can execute commands as other users"
      end
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid user name." % value
      end
    end
  end

  # Autorequire the user running command
  autorequire(:user) do
    self[:user]
  end

  # Autorequire the password file
  autorequire(:file) do
    self[:passwordfile]
  end

  # Autorequire the das domain
  autorequire(:domain) do
    self.catalog.resources.select { |res|
      next unless res.type == :domain
      res if res[:portbase] == self[:dasport]-48
    }.collect { |res|
      res[:name]
    }
  end
end
