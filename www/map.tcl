set root_url [site_node_closest_ancestor_package_url -package_key simulation]
set url [export_vars -base "${root_url}static-map.swf" { root_url }]