$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:deployment_group).provide(:asadmin,
                                   :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish Cluster support."

  def create
    # Start a new args array
    args = Array.new
    args << "create-deployment-group"
    args << @resource[:name]

    # Run the create command
    asadmin_exec(args)

  end

  def destroy
    args = Array.new
    args << "delete-deployment-group" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-deployment-groups"]).each do |line|
      deployment_group = line.split(" ")[0] if line.match(/running/) # Glassfish > 3.0.1
      return true if @resource[:name] == deployment_group
    end
    return false
  end
end
