log_level		:info
log_location		STDOUT
node_name		'workstation'
client_key		'/root/chef-repo/.chef/workstaion.pem'
validation_client_name	'chef-validator'
validation_key		'/root/chef-repo/.chef/chef-validator.pem'
chef_server_url		'https://Chef-server:443'
syntax_check_cache_path	'/root/chef-repo/syntax_check_cache'
cookbook_path [	'/root/chef-repo/cookbooks' ]