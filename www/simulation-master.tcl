set package_id [ad_conn package_id]
set return_url "[ad_conn url]?[ad_conn query]"                
set admin_p [permission::permission_p -object_id $package_id -privilege admin]
set parameters_url [export_vars -base "/shared/parameters" {package_id return_url}]
