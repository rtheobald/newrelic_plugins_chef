# verify java dependency
verify_java 'Galera Plugin'

# check required attributes
verify_attributes do
  attributes [
    'node[:newrelic][:license_key]',
    'node[:newrelic][:galera][:install_path]',
    'node[:newrelic][:galera][:user]',
    'node[:newrelic][:galera][:servers]'
  ]
end

verify_license_key node[:newrelic][:license_key]

install_plugin 'newrelic_galera_plugin' do
  plugin_version   node[:newrelic][:galera][:version]
  install_path     node[:newrelic][:galera][:install_path]
  plugin_path      node[:newrelic][:galera][:plugin_path]
  download_url     node[:newrelic][:galera][:download_url]
  user             node[:newrelic][:galera][:user]
end

# create template newrelic.json file
template "#{node[:newrelic][:galera][:plugin_path]}/config/newrelic.json" do
  source 'galera/newrelic.json.erb'
  action :create
  owner node[:newrelic][:galera][:user]
  mode "0400"
  notifies :restart, "service[newrelic-galera-plugin]"
end

# create template plugin.json file
template "#{node[:newrelic][:galera][:plugin_path]}/config/plugin.json" do
  source 'galera/plugin.json.erb'
  action :create
  owner node[:newrelic][:galera][:user]
  mode "0400"
  notifies :restart, "service[newrelic-galera-plugin]"
end

# install init.d script and start service
plugin_service 'newrelic-galera-plugin' do
  daemon          'plugin.jar'
  daemon_dir      node[:newrelic][:galera][:plugin_path]
  plugin_name     'Galera'
  plugin_version  node[:newrelic][:galera][:version]
  user            node[:newrelic][:galera][:user]
  run_command     "java #{node[:newrelic][:galera][:java_options]} -jar"
end
